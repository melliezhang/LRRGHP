
clc;
clear;
addpath(genpath('Utilities'));
addpath(genpath('Data'));
addpath(genpath('Results'));
Test_image_dir     =    'C:\Users\ak89250\Google Drive\Me\WNNM_code\Data\';

Out_dir        =    'C:\Users\ak89250\Google Drive\Me\WNNM_code\Results\';

imgdir        =  dir( fullfile(Test_image_dir, 'Lena512.tif') );

fd = fopen('psnrssim.txt', 'w+');

for nlevels = [40]
    for  idx  =  1 : length(imgdir)
        
        fprintf([imgdir(idx).name ':\n']);
        pre           =   sprintf('nsig_%d_%s', nlevels, imgdir(idx).name);
        Res_dir       =   strcat(Out_dir, pre);
        Test_img      =    fullfile(Test_image_dir, imgdir(idx).name);
        
        WNNM_DeNoising( nlevels, Res_dir, Test_img, fd );
        
    end
end

fclose(fd);

 