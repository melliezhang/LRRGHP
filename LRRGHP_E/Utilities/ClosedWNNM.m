function [SigmaX,svp]=ClosedWNNM(SigmaY,C,oureps,par)
temp=(SigmaY-oureps).^2-4*(C-oureps*SigmaY); %4
ind=find (temp>0);
svp=length(ind);
SigmaX=max(SigmaY(ind)-oureps+sqrt(temp(ind)),0)/2;%2
%%afoermentioned original 
% c0 = par.c1;
% nsig2 = par.nSig^2; 
% % [n1,n2] = size(SigmaY);
% % a  = length(diag(SigmaY));
% % aa = ones(1,a);
% % K = diag(aa,0);
% % tau = 3*sqrt(n1*n2); 
% sigma = diag(SigmaY);
% % svp = sum(sigma > tau);
% % sigma = sigma(1:svp) - tau; SigmaX = sigma;
% 
% sigma   =   soft(sigma, c0*nsig2);
% svp = sum(sigma > 0);
% SigmaX = sigma(1:svp);
end