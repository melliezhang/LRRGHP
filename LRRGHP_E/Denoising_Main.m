%-------
clc;
clear;
addpath(genpath('Utilities'));
Test_image_dir     =    'GHP_Data\';

Out_dir        =    'Results\';
Noise_dir        =    'Noise\';
% imgdir        =  dir( fullfile(Test_image_dir, '7.tif') );
% 
% fd = fopen('psnrssim1_10.txt', 'w+');
% % % nlevels = [5 15 25 30 40 50 100]
% % for nlevels = [50 100]
% %     for  idx  =  1 : length(imgdir)
% %         
% %         fprintf([imgdir(idx).name ':\n']);
% %         pre           =   sprintf('nsig_%d_%s', nlevels, imgdir(idx).name);
% %         Res_dir       =   strcat(Out_dir, pre);
% %         Test_img      =    fullfile(Test_image_dir, imgdir(idx).name);
% %         Image_Denoising( nlevels, Res_dir, Test_img, fd );
% %         
% %     end
% % end
% 
% fclose(fd);

imgdir        =  dir( fullfile(Test_image_dir, '6.tif') );
fd = fopen('psnrssim2.txt', 'w+');

for nlevels = [30 50 100] %5 10 15 20 25 30 40 50 100
    for  idx  =  1 : length(imgdir)
        
        fprintf([imgdir(idx).name ':\n']);
        pre           =   sprintf('nsig_%d_%s', nlevels, imgdir(idx).name);
        Res_dir       =   strcat(Out_dir, pre);
        Noise_dir       =   strcat(Noise_dir, pre);
        Test_img      =    fullfile(Test_image_dir, imgdir(idx).name);
        [im,par] = Image_Denoising( nlevels, Res_dir, Test_img, fd );
        
    end
end
 
 fclose(fd);

 