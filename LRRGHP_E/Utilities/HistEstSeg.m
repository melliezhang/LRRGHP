function [hist_d, X,dy_es,dy_real]   =   HistEstSeg(hist_n, hist_nim)

% addpath('optimize');

[hist_d, X,dy_es,dy_real]     =   HistEstMain(hist_n, hist_nim);

function    [hist_d, X,dy_es,dy_real]  =   HistEstMain(hist_n, hist_g)
global      SHOW
par.num     =   sum(hist_g);
par.dn          =   hist_n;
par.dy          =   hist_g;

fm  =   Inf;
X       =   0;
A       =   0.001 : 0.5 : 3;
B       =   0.02 : 0.5 : 1.5;
for     ii  =   1 : length(A)-1
    for     jj  =   1 : length(B)-1
        [Xm, feval]         =   optimize(@(x) ObjFun(x, par), [0.08 0.65], [A(ii) B(jj)], [A(ii+1) B(jj+1)], [], [],...
                                        [], [], [], [], optimset('MaxFunEvals', 1e7, 'TolX', 1e-5, 'TolFun', 1e-6));
        if  feval < fm
            fm  =   feval;
            X       =   Xm;
        end
    end
end

x   =   (-255 : 255);
dx  =   exp(-X(1)*abs(x).^X(2));
dx  =   dx/sum(dx)*par.num;
dy  =   conv2(dx(:), par.dn, 'same');
dy  =   [dy(256); dy(257:end)*2]/sum(dy)*par.num;
dy_es = [];
dy_es = [dy_es,dy];
dy_real = [];
dy_real = [dy_real,par.dy];
if  SHOW    ==  1
    figure,  plot(par.dy,'*r');
    hold on
    plot(dy);
    hold off
end
hist_d  =   [dx(256:end)]/sum(dx(256:end));

function fm     =   ObjFun(X, par)           % x1 = lambda, x2 = gamma
x   =   (-255 : 255);
dx  =   exp(-X(1)*abs(x).^X(2));
dx  =   dx/sum(dx)*par.num;
dy  =   conv2(dx(:), par.dn, 'same');
dy  =   [dy(256); dy(257:end)*2]/sum(dy)*par.num;
% fm  =   sum((abs(dy-par.dy).*weight).^2);
% fm  =   sum(dy.*log(dy./(par.dy+eps)).*weight);
fm  =   sqrt(1 - sum(sqrt(dy.*par.dy))/sqrt(sum(dy)*sum(par.dy)));