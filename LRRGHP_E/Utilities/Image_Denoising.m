%----------------------------------------------------
% Blur: 9x9 Uniform kernel; AGWN std Varance = 2^0.5
% Data: May 20th, 2010
% Author: Weisheng Dong, wsdong@mail.xidian.edu.cn
%----------------------------------------------------
function [im,par] = Image_Denoising( nSig, Out_dir,In_dir, fd )

par.nSig      =   nSig;
par.iters     =   1;
par.eps       =   1e-8;
par.cls_num   =   70;   % 70

if nSig<=30
    par.c1        =   0.64;         % 0.57
else    
    par.c1        =   0.64;     
end
par.lamada    =   0.23;  % 0.36
par.hh        =   12;
par.nSig      =   nSig;                                 % Variance of the noise image
par.SearchWin =   30;                                   % Non-local patch searching window
par.delta     =   0.1;                                  % Parameter between each iter
par.c         =   sqrt(2);                              % Constant num for the weight vector
par.Innerloop =   2;                                    % InnerLoop Num of between re-blockmatching
par.ReWeiIter =   3;

if nSig <= 10
    par.c1        =   0.56;   
    par.lamada    =   0.22;
    
    par.sigma     =   1.7;  
    par.win       =   6; %6
    par.nblk      =   13;           
    par.hp        =   75;
    par.K         =   1;
    par.m_num     =   240;
    
    par.patsize       =  7;                            % Patch size
    par.patnum        =   60;                          % Initial Non-local Patch number 70 for high resolution image
    par.Iter          =   8; 8;                            % total iter numbers
    par.lamada        =   0.54;      
elseif nSig<=15
    par.c1        =   0.59;   
    par.lamada    =   0.22;
    
    par.sigma     =   1.8;
    par.win       =   6;
    par.nblk      =   13;           
    par.hp        =   75;
    par.K         =   2;
    par.m_num     =   240;   
    
    par.patsize       =   7;                            % Patch size
    par.patnum        =   60;                           % Initial Non-local Patch number 70
    par.Iter          =   8; %8;                            % total iter numbers
    par.lamada        =   0.54;      
elseif nSig <=30
    par.c1        =   0.64; 
    par.sigma     =   2.0;
    par.win       =   7;
    par.nblk      =   16;
    par.hp        =   80;       %  80
    par.K         =   2;
    par.m_num     =   250;
    
    par.patsize       =   7;%7
    par.patnum        =    95;% 90; 100 80
    par.Iter          =   11;%8;
    par.lamada        =   0.56; 
elseif nSig<=50
    par.c1        =   0.64;    
    
    par.sigma     =   2.4;
    par.win       =   9;
    par.nblk      =   18;
    par.hp        =   90;
    par.K         =   2;
    par.m_num     =   300;
    par.lamada    =   0.26;  
    
    par.patsize       =   7;
    par.patnum        =   100;% 90;100 for testing
    par.Iter          =  12 ; % 10;
    par.lamada        =   0.56; 
 elseif nSig<=60
    par.c1           =   0.67;   
    par.patsize       =   8;
    par.patnum        =   120;
    par.Iter          =   12;
    par.lamada        =   0.58;    
else
    par.c1        =   0.74;  
    par.sigma     =   2.4;
    par.win       =   8;
    par.nblk      =   20;
    par.hp        =   95;
    par.K         =   2;
    par.m_num     =   300;
    par.lamada    =    0.26;
    
    par.patsize       =   9; %9
    par.patnum        =   130;
    par.Iter          =   14;
    par.lamada        =   0.58; 
end
    par.step      =   floor((par.patsize)/2-1);    
randn('seed', 0);
I      =   double( imread(In_dir) );    % load image to manipulate noisy image, load mask
nim =   I + nSig*randn( size(I) );

%imwrite(nim/255, Noise_dir);
par.mask = KmeansSeg(nim, par);

global      SHOW            % if you don't want to see the mid-processing results, set this variable to 0

SHOW        =   0;


par.I   =   I;
par.nim     =   nim;

[par.hist_dh, par.hist_dv, par.par_h, par.par_v] = HMSeg(par.nim, par.mask, nSig);

[im, ~, ~,par]   =   Centralized_SR_Denoising_IDR2( par );

imwrite(im/255, Out_dir);

dim = double( imread(Out_dir) );

PSNR = csnr(dim, I, 0, 0);
SSIM = cal_ssim(dim, I, 0, 0);
FSIM = FeatureSIM(dim, I);

fprintf(fd, '%s: PSNR = %3.2f  SSIM = %f FSIM = %f\n', In_dir, PSNR, SSIM, FSIM);
% disp(sprintf('Total elapsed time = %f min\n', (etime(clock,time0)/60) ));
return;

