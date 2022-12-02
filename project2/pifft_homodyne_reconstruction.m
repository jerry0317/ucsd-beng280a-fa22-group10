function [output,selected,Wkxy,weighted,If_selected,If_weighted] = pifft_homodyne_reconstruction(I_f, xmin, xmax, ymin, ymax, weight_func, weight_smooth, weight_smooth_factor)
    % NOTE: The actual output is real(output)
    arguments
        I_f; % Input k-image
        xmin = 1; 
        xmax = -1;
        ymin = 1;
        ymax = -1;
        weight_func = "linear";
        weight_smooth = false;
        weight_smooth_factor = 1;
    end
    assert(all(mod(size(I_f),2) == [0,0]));

    I_f1 = zeros(size(I_f));
    I_f1(ymin:ymax, xmin:xmax) = I_f(ymin:ymax, xmin:xmax);

    if xmax == -1
        xmax = size(I_f,2);
    end

    if ymax == -1
        ymax = size(I_f,1);
    end

%     assert((xmin == 1 || xmax == size(I_f,2)));
%     assert((ymin == 1 || ymax == size(I_f,1)));

    xpad = max(xmin, size(I_f,2)-xmax);
    ypad = max(ymin, size(I_f,1)-ymax);

    I_f2 = zeros(size(I_f));
    I_f2(ypad:size(I_f,1)-ypad+1, xpad:size(I_f,2)-xpad+1) = I_f(ypad:size(I_f,1)-ypad+1, xpad:size(I_f,2)-xpad+1);
    selected = I_f2;

    I_if2 = fftshift(ifft2(ifftshift(I_f2)));
    If_selected = I_if2;

    nx = size(I_f,2);
    Wx1d = zeros(1,nx);
    Wx1d(1:xpad) = 1;
    if weight_func == "linear"
        Wx1d(xpad+1:nx-xpad) = (nx-2*xpad-1:-1:0)/(nx-2*xpad);
    elseif weight_func == "step"
        Wx1d(xpad+1:nx-xpad) = 0.5;
    end
    if weight_smooth
        Wx1d = smoothdata(Wx1d, 'Gaussian', xpad * weight_smooth_factor);
    end
    Wkx = repmat(Wx1d,[nx 1]);

    if xmin > nx-xmax
        Wkx = rot90(Wkx,2);
    end

    ny = size(I_f,1);
    Wy1d = zeros(ny,1);
    Wy1d(1:ypad) = 1;
    if weight_func == "linear"
        Wy1d(ypad+1:ny-ypad) = (ny-2*ypad-1:-1:0)/(ny-2*ypad);
    elseif weight_func == "step"
        Wy1d(ypad+1:ny-ypad) = 0.5;
    end

    if weight_smooth
        Wy1d = smoothdata(Wy1d, 'Gaussian', ypad * weight_smooth_factor);
    end
    Wky = repmat(Wy1d,[1 ny]);

    if ymin > ny-ymax
        Wky = rot90(Wky,2);
    end

    Wkxy = Wkx .* Wky .* 4;

    I_fw = I_f1 .* Wkxy;
    weighted = I_fw;
    I_ifw = fftshift(ifft2(ifftshift(I_fw)));
    If_weighted = I_ifw;

    output = I_ifw .* exp(-1i*angle(I_if2));

end