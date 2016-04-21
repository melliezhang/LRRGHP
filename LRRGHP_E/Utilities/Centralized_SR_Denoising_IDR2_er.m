function [im_out PSNR SSIM par ]   =  Centralized_SR_Denoising_IDR2( par )
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

[d_im,par]     =   Denoising(n_im, par, ori_im);

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


function  [d_im,par]    =   Denoising(n_im, par, ori_im)
t0 = cputime;
[h1 w1]     =   size(n_im);
b2          =   par.win*par.win;

V           =   zeros([h1 w1]);
U           =   zeros([h1 w1]);
w           =   zeros([h1 w1]);
Y           =   sign(n_im);
%E_hat       =   zeros([h1 w1]);
E_hat       =   sparse([h1 w1]);
norm_two = norm(Y,2);
mu = 2/norm_two- eps; % this one can be tuned (former is mu = .5/norm_two -eps )
rho = 24;  %16; 

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
lamada      =   0.009;   % 0.1
v           =   par.nSig;
cnt         =   1;

hist_refh   =   par.hist_dh;
hist_refv   =   par.hist_dv;

par.miu = 3e-1;% 3e-1;
PSNRformer  =   0;
SSIMformer  =   0;

[dh, dv] = HistMatShrinkageSeg( d_im, hist_refh, hist_refv, par.mask);

for k    =  1 : par.Iter  

        Q_im       =   n_im;                            %matrix of observations/data (required input)
        temp_E     =   E_hat;
        [dh0, dv0] = Ltrans2(d_im);

        delta_dh    =   1/par.miu*(dh0-dh);
        delta_dv    =   1/par.miu*(dv0-dv);
        partitem    =   Lforward2(delta_dh, delta_dv);
        d_im        =   d_im + lamada*( (Q_im - d_im))- partitem;  % n_im - d_im  0.02
        temp_Z      =   d_im + V/mu;
        [CurPat Sigma_arr]	=	Im2Patch( temp_Z, n_im, par );                      % image to patch and estimate local noise variance 
        
        if (mod(k-1,par.Innerloop)==0) %par.Innerloop
        par.patnum = par.patnum-10;                                             % Lower Noise level, less NL patches
        NL_mat  =  Block_matching(CurPat, par, Neighbor_arr, Num_arr, Self_arr);% Caculate Non-local similar patches for each 
        if(k==1)
            Sigma_arr = par.nSig * ones(size(Sigma_arr));                       % First Iteration use the input noise parameter
        end
        end       
       lamada      =   0.01;
       [EPat, W]  =  PatEstimation( NL_mat, Self_arr, Sigma_arr, CurPat, par);   % Estimate all the patches
       [d_im,E_Img,W_Img]      =  Patch2Im( EPat, W, par.patsize, Height, Width );            % P low rank matrix
       Img        =  (E_Img + eps*d_im)./(W_Img+eps);
       temp       =  d_im(:);
       [X flag0]       =   pcg( @(x) Afun(x,w(:), lamada, W_Img(:)), temp, 0.4E-6, 400, [], [], d_im(:));          
       P_im              =   reshape(X, h1, w1);  


       %update E
        temp       =  Q_im - Img + U/mu;
       % E_hat      =  max(0,temp./(11 + mu));
       % E_hat     =  solve_l1l2(temp,lamada/mu);
       % E_hat = max(0,temp - lamada/mu) + min(0, temp + lamada/mu);
       [dh, dv]  =  HistMatShrinkageSeg( P_im, hist_refh, hist_refv, par.mask);
        PSNR        =   csnr( P_im(2:h1-1,2:w1-1), ori_im(2:h1-1,2:w1-1), 0, 0 ); 
        SSIM        =   cal_ssim( P_im(2:h1-1,2:w1-1), ori_im(2:h1-1,2:w1-1), 0, 0 );
         if (PSNRformer >= PSNR || SSIMformer >= SSIM)
             break;
        else   
        PSNRformer  =   PSNR;
        SSIMformer  =   SSIM;
       

        fprintf( 'Preprocessing, Iter %d : PSNR = %f, SSIM = %f, nsig = %3.2f\n', cnt, PSNR, SSIM, par.nSig );
        cnt   =  cnt + 1;
        
        H1    =  Q_im - Img; %  - E_hat;
        H2    =  P_im - d_im;
        H3    =  partitem;
        
        V     =  V + mu*H1;
        U     =  U + mu*H2;
    %    w    =  mu*H3;
        mu    =  rho * mu;
        d_im  =   P_im; 
        imwrite(d_im/255, 'tmp.tif');
        clock;
        par.time(k)= cputime-t0;
        par.psnr(k) = PSNR;
        end 
end
function  y  =  Afun(x,w, eta, Wei)
y      = 0.* eta.*w + x;  % eta * (Wei.*x);
return;
