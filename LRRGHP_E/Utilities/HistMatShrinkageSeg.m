function [dh, dv] = HistMatShrinkageSeg( d_im, hist_refh, hist_refv, mask)

class_num   =   size(mask, 3);

[dh, dv] = Ltrans2(d_im);
[rh, ch]      =   size(dh);
dh          =   dh(:);
[rv, cv]        =   size(dv);
dv              =   dv(:);

for ind     =   1 : class_num
    masktmp     =   mask(:, :, ind);
    
    masktmph    =   masktmp(1:rh, 1:ch);
    lable       =   masktmph(:) > 0;
    dhm         =   dh(lable);
    ghm         =   hist_refh(:, :, ind);
    sign_dh     =   sign(dhm);
    dh0             =   255*histeq(abs(dhm)/255, ghm);
    dh0 = min(2*abs(dhm), dh0); %former 
    %dh0 = min(0.9*abs(dhm), dh0);
    dh0  = sign_dh .* dh0;
    dh(lable)       =   dh0;
    
    masktmpv    =   masktmp(1:rv, 1:cv);
    lable       =   masktmpv(:) > 0;
    dvm         =   dv(lable);
    gvm         =   hist_refv(:, :, ind);
    sign_dv     =   sign(dvm);
    dv0             =   255*histeq(abs(dvm)/255, gvm);
    dv0 = min(2*abs(dvm), dv0); %former
    %dv0 = min(0.9*abs(dvm), dv0);
    dv0  = sign_dv .* dv0;
    dv(lable)       =   dv0;
end

dh      =   reshape(dh, rh, ch);
dv      =   reshape(dv, rv, cv);
