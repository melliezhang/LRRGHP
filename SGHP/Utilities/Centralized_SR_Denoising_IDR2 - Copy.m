function [im_out PSNR SSIM ]   =  Centralized_SR_Denoising_IDR2( par )

nim           =   par.nim;
[h  w ch]     =   size(nim);

par.step      =   1;
par.h         =   h;
par.w         =   w;

dim         =   uint8(zeros(h, w, ch));
ori_im      =   zeros(h,w);

% RGB->YUV

n_im           =   nim;

if isfield(par, 'I')
    ori_im             =   par.I;
end

fprintf('PSNR of the noisy image = %f \n', csnr(n_im(1:h,1:w), ori_im, 0, 0) );

[d_im]     =   Denoising(n_im, par, ori_im);

PSNR = 0;
SSIM = 0;

if isfield(par,'I')
   [h w ch]  =  size(par.I);
   PSNR      =  csnr( d_im(2:h-1,2:w-1), ori_im(2:h-1,2:w-1), 0, 0 );
   SSIM      =  cal_ssim( d_im(2:h-1,2:w-1), ori_im(2:h-1,2:w-1), 0, 0 );
end

im_out  =  d_im;

return;


function  [d_im]    =   Denoising(n_im, par, ori_im)

[h1 w1]     =   size(n_im);
b2          =   par.win*par.win;

par.tau1    =   0.1;
par.tau2    =   0.2;
par.tau3    =   0.3;
d_im        =   n_im;
lamada      =   0.02;   % 0.1
v           =   par.nSig;
cnt         =   1;


hist_refh   =   par.hist_dh;
hist_refv   =   par.hist_dv;

par.miu = 4e-1;% 3e-1;

[dh, dv] = HistMatShrinkageSeg( d_im, hist_refh, hist_refv, par.mask);

for k    =  1 

    Dict          =   KMeans_PCA( d_im, par, par.cls_num );

    [blk_arr, wei_arr]     =   Block_matching( d_im, par);
%------------------
 for i  =  1:3
        d_im    =   d_im + lamada*(n_im - d_im);
        dif     =   d_im-n_im;
        vd      =   v^2-(mean(mean(dif.^2)));
        
        if (i ==1 && k==1)
            par.nSig  = sqrt(abs(vd));            
        else
            par.nSig  = sqrt(abs(vd))*par.lamada;
        end
        
        [alpha, beta, Tau1]   =   Cal_Parameters( d_im, par, Dict, blk_arr, wei_arr );   
        
        d_im        =   NCSR_Shrinkage( d_im, par, alpha, beta, Tau1, Dict, 1 );

        PSNR        =   csnr( d_im(1:h1,1:w1), ori_im, 0, 0 );
        fprintf( 'Preprocessing, Iter %d : PSNR = %f,   nsig = %3.2f\n', cnt, PSNR, par.nSig );
        cnt   =  cnt + 1;
        imwrite(d_im./255, 'Results\tmp.tif');
 end

end

for k    =  2 : par.K+2

     Dict          =   KMeans_PCA( d_im, par, par.cls_num );

    [blk_arr, wei_arr]     =   Block_matching( d_im, par);

%---------------------------------------
    
    for i = 1 : 2
        [dh0, dv0] = Ltrans2(d_im);

        delta_dh    =   1/par.miu*(dh0-dh);
        delta_dv    =   1/par.miu*(dv0-dv);
        partitem    =   Lforward2(delta_dh, delta_dv);
        
        d_im    =   d_im + lamada*( (n_im - d_im) - partitem );
        
        dif     =   d_im-n_im;
        vd      =   v^2-(mean(mean(dif.^2)));
        
        if (i ==1 && k==1)
            par.nSig  = sqrt(abs(vd));            
        else
            par.nSig  = sqrt(abs(vd))*par.lamada;
        end
        
        [alpha, beta, Tau1]   =   Cal_Parameters( d_im, par, Dict, blk_arr, wei_arr );   
        
        d_im        =   CSR_Shrinkage( d_im, par, alpha, beta, Tau1, Dict, 1 );

        [dh, dv] = HistMatShrinkageSeg( d_im, hist_refh, hist_refv, par.mask);
        
        PSNR        =   csnr( d_im(2:h1-1,2:w1-1), ori_im(2:h1-1,2:w1-1), 0, 0 );
        SSIM         =   cal_ssim( d_im(2:h1-1,2:w1-1), ori_im(2:h1-1,2:w1-1), 0, 0 );

        fprintf( 'Preprocessing, Iter %d : PSNR = %f, SSIM = %f, nsig = %3.2f\n', cnt, PSNR, SSIM, par.nSig );
        cnt   =  cnt + 1;
        
        imwrite(d_im/255, 'tmp.tif');
    end    

end

