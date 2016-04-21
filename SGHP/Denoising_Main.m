%------------------------------------------------------------------------------------------------------------
% Gradient Histogram Estimation and Preservation for Texture Enhanced Image Denoising
% Author: Wangmeng Zuo, Lei Zhang, Chunwei Song, David Zhang, Huijun Gao
%------------------------------------------------------------------------------------------------------------
clc;
clear;
addpath(genpath('Utilities'));
Test_image_dir     =    'GHP_Data\';

Out_dir        =    'Results\';

imgdir        =  dir( fullfile(Test_image_dir, 'Lena512.tif') );

fd = fopen('psnrssim.txt', 'w+');

for nlevels = [40]
    for  idx  =  1 : length(imgdir)
        
        fprintf([imgdir(idx).name ':\n']);
        pre           =   sprintf('nsig_%d_%s', nlevels, imgdir(idx).name);
        Res_dir       =   strcat(Out_dir, pre);
        Test_img   =    fullfile(Test_image_dir, imgdir(idx).name);
        Image_Denoising( nlevels, Res_dir, Test_img, fd );
        
    end
end

fclose(fd);

 