function [E_Img]   =  WNNM_DeNoising( nSig, Out_dir,In_dir, fd )
PSNRformer = 0;
SSIMformer = 0;
time0 = clock;
t0    = cputime;

Par   = ParSet(nSig);   
par.nSig      =   nSig;
randn('seed', 0);
O_Img      =   double( imread(In_dir) );    % load image to manipulate noisy image, load mask
N_Img      =   O_Img + nSig*randn( size(O_Img) );
E_Img      =   N_Img; 
PSNR       =  csnr( N_Img, O_Img, 0, 0 );
fprintf( 'Noisy Image: nSig = %2.3f, PSNR = %2.2f \n\n\n', nSig, PSNR );

                                                       % Estimated Image
[Height Width]  = size(E_Img);   
TotalPatNum     = (Height-Par.patsize+1)*(Width-Par.patsize+1);                 %Total Patch Number in the image
Dim             = Par.patsize*Par.patsize;  


[Neighbor_arr Num_arr Self_arr] =	NeighborIndex(N_Img, Par);                  % PreCompute the all the patch index in the searching window 
            NL_mat              =   zeros(Par.patnum,length(Num_arr));          % NL Patch index matrix
            CurPat              =   zeros( Dim, TotalPatNum );
            Sigma_arr           =   zeros( 1, TotalPatNum);            
            EPat                =   zeros( size(CurPat) );     
            W                   =   zeros( size(CurPat) );          
            
for iter = 1 : Par.Iter        
    E_Img             	=	E_Img + Par.delta*(N_Img - E_Img);
    [CurPat Sigma_arr]	=	Im2Patch( E_Img, N_Img, Par );                      % image to patch and estimate local noise variance            
    
    if (mod(iter-1,Par.Innerloop)==0)
        Par.patnum = Par.patnum-10;                                             % Lower Noise level, less NL patches
        NL_mat  =  Block_matching(CurPat, Par, Neighbor_arr, Num_arr, Self_arr);% Caculate Non-local similar patches for each 
        if(iter==1)
            Sigma_arr = Par.nSig * ones(size(Sigma_arr));                       % First Iteration use the input noise parameter
        end
    end       

     [EPat, W]  =  PatEstimation( NL_mat, Self_arr, Sigma_arr, CurPat, Par );   % Estimate all the patches
     E_Img      =  Patch2Im( EPat, W, Par.patsize, Height, Width );             
     PSNR = csnr(O_Img, E_Img, 0, 0 );
     SSIM = cal_ssim(O_Img, E_Img, 0, 0 );
     FSIM = FeatureSIM(E_Img, O_Img);
%      if (PSNRformer >= PSNR || SSIMformer >= SSIM)
%             break;
%         else   
        PSNRformer  =   PSNR;
        SSIMformer  =   SSIM;
        time0          =   cputime - t0;
    fprintf( 'Iter = %2.3f, PSNR = %3.2f SSIM = %f FSIM = %3.2f TIME = %3.2f \n',iter, PSNR, SSIM, FSIM,time0);
%      end
end
clock;

imwrite(E_Img/255, Out_dir);

%fprintf(fd, '%s: PSNR = %3.2f  SSIM = %f FSIM = %f\n\n', In_dir, PSNR, SSIM, FSIM);
disp(sprintf('Total elapsed time = %f min\n', (etime(clock,time0)/60) ));
return;


