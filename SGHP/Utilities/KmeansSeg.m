function mask = KmeansSeg(nim, par)

win = par.win;
cls_num = 6;    % cluster number is cls_num + 1

b         =   win;
psf       =   fspecial('gauss', win+2, par.sigma);
[Y, X, Z]    =   Get_patches(nim, b, psf, 1, 1);    

% Compute PCA for the smooth patches
delta       =   sqrt(par.nSig^2+16);
v           =   sqrt( mean( Y.^2 ) );
[~, i0]     =   find( v<delta );

cls_idx   =  ones( size(Y, 2), 1 );

% Clustering
itn       =   14;
m_num     =   40000;
rand('seed',0);

[cls_idxp, ~, cls_num]   =  My_kmeans([Y; X; Z], cls_num, itn, m_num, par.nSig);
cls_idx( cls_idx ~= 0 ) = cls_idxp;

[h, w] = size(nim);
N = h - win + 1;
M = w- win + 1;

hwin = floor(win/2);

mask = zeros( h, w, cls_num );

for cn = 1 : cls_num
    L = ones( size(cls_idx) );
    L = L.*( cls_idx == cn );
    mask(hwin+1:end-(win-hwin-1), hwin+1:end-(win-hwin-1), cn) = reshape(L, N, M);
end




%--------------------------------------------------
function  [Py  Px Pz]  =  Get_patches( im, b, psf, s, scale )
im        =  imresize( im, scale, 'bilinear' );

[h w ch]  =  size(im);
ws        =  floor( size(psf,1)/2 );

if  ch==3
    lrim      =  rgb2ycbcr( uint8(im) );
    im        =  double( lrim(:,:,1));    
end

lp_im     =  conv2( psf, im );
lp_im     =  lp_im(ws+1:h+ws, ws+1:w+ws);
hp_im     =  im - lp_im;

N         =  h-b+1;
M         =  w-b+1;
% s         =  1;
r         =  [1:s:N];
r         =  [r r(end)+1:N];
c         =  [1:s:M];
c         =  [c c(end)+1:M];
L         =  length(r)*length(c);
Py        =  zeros(b*b, L, 'single');
Px        =  zeros(b*b, L, 'single');

[Pzx, Pzy] = meshgrid(c+floor(b/2), r+floor(b/2));
Pzx = Pzx(:)';
Pzy = Pzy(:)';
Pz = [Pzy; Pzx];

k    =  0;
for i  = 1:b
    for j  = 1:b
        k       =  k+1;
        blk     =  hp_im(r-1+i,c-1+j);
        Py(k,:) =  blk(:)';
        
        blk     =  im(r-1+i,c-1+j);
        Px(k,:) =  blk(:)';        
    end
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------
function   [cls_idx,vec,cls_num]  =  My_kmeans(Y, cls_num, itn, m_num, nSig)
Y         =   Y';
[L b2]    =   size(Y);
k3 = 2;
k1 = (b2-2)/2;
k2 = k1;

h1 = 2*nSig^2;
h2 = 2*nSig^2;
h3 = 50;

if nSig <= 25
    p1 = 5; p2 = 8;
elseif nSig <= 30
    p1 = 5; p2 = 7;
else
    p1 = 5; p2 = 5;
end

P         =   randperm(L);
P2        =   P(1:cls_num);
vec       =   Y(P2(1:end), :);

for i = 1 : itn
    
    cnt       =  zeros(1, cls_num);    
    
    v_dis    =   zeros(L, cls_num);
    v_dis1  = v_dis;
    v_dis2 = v_dis;
    v_dis3 = v_dis;
    for  k = 1 : cls_num
        v_dis1(:, k) = (Y(:,1) - vec(k,1)).^2;
        for c = 2:k1
            v_dis1(:,k) =  v_dis1(:,k) + (Y(:,c) - vec(k,c)).^2;
        end
    end
    v_dis1 = exp(-v_dis1/k1/h1);
    
    for  k = 1 : cls_num
        v_dis2(:, k) = (Y(:,k1+1) - vec(k,k1+1)).^2;
        for c = 2:k2
            v_dis2(:,k) =  v_dis2(:,k) + (Y(:,k1+c) - vec(k,k1+c)).^2;
        end
    end
    v_dis2 = exp(-v_dis2/k2/h2);
    
    for  k = 1 : cls_num
        v_dis3(:, k) = (Y(:,k1+k2+1) - vec(k,k1+k2+1)).^2;
        for c = 2:k3
            v_dis3(:,k) =  v_dis3(:,k) + (Y(:,k1+k2+c) - vec(k,k1+k2+c)).^2;
        end
    end
    v_dis3 = exp(-v_dis3/h3);
    
    v_dis = p1*v_dis1+p2*v_dis2;%+100*v_dis3;

    [~, cls_idx]     =   min(v_dis, [], 2);
    
    [s_idx, seg]   =  Proc_cls_idx( cls_idx );
    for  k  =  1 : length(seg)-1
        idx    =   s_idx(seg(k)+1:seg(k+1));    
        cls    =   cls_idx(idx(1));    
        vec(cls,:)    =   mean(Y(idx, :));
        cnt(cls)      =   length(idx);
    end        
    
    if (i==itn-2)
        [val ind]  =  min( cnt );       % Remove these classes with little samples        
        while (val<m_num) && (cls_num>=3)
            vec(ind, :)    =  [];
            cls_num       =  cls_num - 1;
            cnt(ind)      =  [];

            [val  ind]    =  min(cnt);
        end        
    end
    

end
