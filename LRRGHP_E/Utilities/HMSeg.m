function    [hist_dh, hist_dv, par_h, par_v] = HMSeg(nim, mask, nsig)

global      SHOW

class_num  = size(mask, 3);

histest_dh  =   zeros(256, 1, class_num);
histest_dv  =   zeros(256, 1, class_num);

par_h               =   zeros(class_num, 2);% save the optimal histogram distribution parameters of each cluster. lambda and gamma for each row
par_v               =   zeros(class_num, 2);

[dnh, dnv]     =   Ltrans2(nim/255);


for     ind     =   1 : class_num
    masktp      =   mask(:, :, ind);
    if sum(masktp(:)>0) > 5000
        sigma = 1.01*nsig*sqrt(2);
    else
        sigma = 1.02*nsig*sqrt(2);
    end
    wsize = 2*round(sigma*3) + 1;
    H{ind} = fspecial('gaussian', [wsize,1], sigma);
end

for     ind     =   1 : class_num
    masktp      =   mask(:, :, ind);
    [histest_dh(:, :, ind), par_h(ind, :)]     =   HistEstMask(masktp, H{ind}, dnh);
    [histest_dv(:, :, ind), par_v(ind, :)]     =   HistEstMask(masktp, H{ind}, dnv);
end

hist_dh     =   histest_dh;
hist_dv     =   histest_dv;

function    [hist_d, X]  =   HistEstMask(mask, hist_n, hist_nim)

mask        =   mask(1:size(hist_nim, 1), 1:size(hist_nim, 2));
% mask        =   ones(size(mask));
mask        =   mask(:);
hist_nim    =   hist_nim(:);
hist_nimseg     =   hist_nim(mask > 0);
hist_nimseg     =   hist_nimseg(hist_nimseg <= 1);
hist_nim    =   imhist(abs(hist_nimseg));
%[hist_d, X,]      =   HistEstSeg(hist_n, hist_nim);
[hist_d, X,dy_es,dy_real] =   HistEstSeg(hist_n, hist_nim);
%  figure,  plot(dy_es,'-*b','LineWidth',2);
%     hold on
%     plot(dy_real,'-r','LineWidth',2);
%     hold off
% legend('Real','Estimation');