clear
clc

I = imread('tm12.png');
nsig_20_4 = imread('tm12Noise.png');
nsig_100_4_e = imread('tm12our.png');
nsig_100_4   = imread('tm12BM3D.png');
nsig_100_4_saist  = imread('tm12SAIST.png');
nsig_100_4_ncsr   = imread('tm12WNNM.png');
nsig_100_4_sghp   = imread('tm12SGHP.png');
nsig_100_4_wnnm   = imread('tm12WNNM.png');

imshow(I)
[crp ,rect]= imcrop;
crp_noise       = imcrop(nsig_20_4,rect);
crp_e       = imcrop(nsig_100_4_e,rect);
crp_n       = imcrop(nsig_100_4,rect);
crp_saist   = imcrop(nsig_100_4_saist,rect);
crp_ncsr   = imcrop(nsig_100_4_ncsr,rect);
crp_sghp   = imcrop(nsig_100_4_sghp,rect);
crp_wnnm   = imcrop(nsig_100_4_wnnm,rect);

scale = 2.0; % set waht you want

crp = imresize(crp,2,'bicubic');
crp_noise = imresize(crp_noise,2,'bicubic');
crp_e = imresize(crp_e,2,'bicubic');
crp_n = imresize(crp_n,2,'bicubic');
crp_saist = imresize(crp_saist,2,'bicubic');
crp_ncsr = imresize(crp_ncsr,2,'bicubic');
crp_sghp = imresize(crp_sghp,2,'bicubic');
crp_wnnm = imresize(crp_wnnm,2,'bicubic');
[r,c,d] = size(crp);
[R,C,D] = size(I);
I(R-r+1:end,C-c+1:end,:) = crp;
nsig_20_4(R-r+1:end,C-c+1:end,:) = crp_noise;
nsig_100_4_e(R-r+1:end,C-c+1:end,:) = crp_e;
nsig_100_4(R-r+1:end,C-c+1:end,:) = crp_n;
nsig_100_4_saist(R-r+1:end,C-c+1:end,:) = crp_saist;
nsig_100_4_ncsr(R-r+1:end,C-c+1:end,:) = crp_ncsr;
nsig_100_4_sghp(R-r+1:end,C-c+1:end,:) = crp_sghp;
nsig_100_4_wnnm(R-r+1:end,C-c+1:end,:) = crp_wnnm;

I = insertShape(I,'Rectangle',rect, 'LineWidth', 3 ,'Color', 'g');
rect2 = [C-c+1 R-r+1 c r];
I = insertShape(I,'Rectangle',rect2, 'LineWidth', 3 ,'Color', 'g');
I_noise = insertShape(nsig_20_4,'Rectangle',rect2, 'LineWidth', 3 ,'Color', 'g');
I2 = insertShape(nsig_100_4_e,'Rectangle',rect2, 'LineWidth', 3 ,'Color', 'g');
I3 = insertShape(nsig_100_4,'Rectangle',rect2, 'LineWidth', 3 ,'Color', 'g');
I4 = insertShape(nsig_100_4_saist,'Rectangle',rect2, 'LineWidth', 3 ,'Color', 'g');
Incsr = insertShape(nsig_100_4_ncsr,'Rectangle',rect2, 'LineWidth', 3 ,'Color', 'g');
Isghp = insertShape(nsig_100_4_sghp,'Rectangle',rect2, 'LineWidth', 3 ,'Color', 'g');
Iwnnm = insertShape(nsig_100_4_wnnm,'Rectangle',rect2, 'LineWidth', 3 ,'Color', 'g');


imwrite(I,'tm12_40.png')
imwrite(I3,'nsig_40_tm12_bm3d.png')
imwrite(I4,'nsig_40_tm12_saist.png')
imwrite(I2,'nsig_40_tm12_proposed.png')
imwrite(I_noise,'nsig_40_tm12_noise1.png')
imwrite(Incsr,'nsig_40_tm12_ncsr.png')
imwrite(Isghp,'nsig_40_tm12_sghp.png')
imwrite(Iwnnm,'nsig_40_tm12_wnnm.png')