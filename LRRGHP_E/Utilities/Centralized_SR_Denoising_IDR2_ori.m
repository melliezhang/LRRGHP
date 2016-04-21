function [im_out PSNR SSIM ]   =  Centralized_SR_Denoising_IDR2( par )
time0 = clock;
nim           =   par.nim;
[h  w ch]     =   size(nim);

E_Img           = par.nim;                                                      % Estimated Image
[Height Width]  = size(E_Img);   
TotalPatNum     = (Height-par.patsize+1)*(Width-par.patsize+1);                 %Total Patch Number in the image
Dim             = par.patsize*par.patsize;  
[Neighbor_arr Num_arr Self_arr] =	NeighborIndex(nim, par);                  % PreCompute the all the patch index in the searching window 
           

par.Height    =   Height;
par.Width     =   Width;
par.TotalPatNum   =   TotalPatNum;
par.Dim           =   Dim ;
par.Neighbor_arr      =   Neighbor_arr;
par.Num_arr           =   Num_arr;
par.Self_arr          =   Self_arr;

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
   disp(sprintf('Total elapsed time = %f min\n', (etime(clock,time0)/60) ));
im_out  =  d_im;

return;


function  [d_im]    =   Denoising(n_im, par, ori_im)

[h1 w1]     =   size(n_im);
b2          =   par.win*par.win;

Height    =   par.Height;
Width     =   par.Width;
TotalPatNum   =   par.TotalPatNum;
Dim           =   par.Dim ;
Neighbor_arr      =   par.Neighbor_arr;
Num_arr           =   par.Num_arr;
Self_arr          =   par.Self_arr;

 NL_mat              =   zeros(par.patnum,length(Num_arr));          % NL Patch index matrix
            CurPat              =	zeros( Dim, TotalPatNum );
            Sigma_arr           =   zeros( 1, TotalPatNum);            
            EPat                =   zeros( size(CurPat) );     
            W                   =   zeros( size(CurPat) );          


par.tau1    =   0.1;
par.tau2    =   0.2;
par.tau3    =   0.3;
d_im        =   n_im;
lamada      =   0.01;   % 0.1
v           =   par.nSig;
cnt         =   1;

hist_refh   =   par.hist_dh;
hist_refv   =   par.hist_dv;

par.miu = 4e-1;% 3e-1;
PSNRformer  =   0;
SSIMformer  =   0;

[dh, dv] = HistMatShrinkageSeg( d_im, hist_refh, hist_refv, par.mask);

for k    =  1 : par.Iter  

        [dh0, dv0] = Ltrans2(d_im);

        delta_dh    =   1/par.miu*(dh0-dh);
        delta_dv    =   1/par.miu*(dv0-dv);
        partitem    =   Lforward2(delta_dh, delta_dv);
        d_im        =   d_im + lamada*( (n_im - d_im)- partitem);  % 
        [CurPat Sigma_arr]	=	Im2Patch( d_im, n_im, par );                      % image to patch and estimate local noise variance 
        if (mod(k-1,par.Innerloop)==0)
        par.patnum = par.patnum-10;                                             % Lower Noise level, less NL patches
        NL_mat  =  Block_matching(CurPat, par, Neighbor_arr, Num_arr, Self_arr);% Caculate Non-local similar patches for each 
        if(k==1)
            Sigma_arr = par.nSig * ones(size(Sigma_arr));                       % First Iteration use the input noise parameter
        end
        end       

       [EPat, W]  =  PatEstimation( NL_mat, Self_arr, Sigma_arr, CurPat, par);   % Estimate all the patches
        d_im      =  Patch2Im( EPat, W, par.patsize, Height, Width ); 

        [dh, dv]  =  HistMatShrinkageSeg( d_im, hist_refh, hist_refv, par.mask);
        
        PSNR        =   csnr( d_im(2:h1-1,2:w1-1), ori_im(2:h1-1,2:w1-1), 0, 0 ); 
        SSIM        =   cal_ssim( d_im(2:h1-1,2:w1-1), ori_im(2:h1-1,2:w1-1), 0, 0 );
        if (PSNRformer >= PSNR || SSIMformer >= SSIM)
            break;
        else   
        PSNRformer  =   PSNR;
        SSIMformer  =   SSIM;
       

        fprintf( 'Preprocessing, Iter %d : PSNR = %f, SSIM = %f, nsig = %3.2f\n', cnt, PSNR, SSIM, par.nSig );
        cnt   =  cnt + 1;
        
        imwrite(d_im/255, 'tmp.tif');
        clock;
        end 
end

