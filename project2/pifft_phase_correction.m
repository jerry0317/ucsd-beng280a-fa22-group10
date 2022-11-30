function [output,padded,selected,If_padded,If_selected] = pifft_phase_correction(I_f, xmin, xmax, ymin, ymax)
    arguments
        I_f; % Input k-image
        xmin = 1; 
        xmax = -1;
        ymin = 1;
        ymax = -1;
    end
    assert(all(mod(size(I_f),2) == [0,0]));

    if xmax == -1
        xmax = size(I_f,2);
    end

    if ymax == -1
        ymax = size(I_f,1);
    end

    I_f1 = zeros(size(I_f));
    I_f1(ymin:ymax, xmin:xmax) = I_f(ymin:ymax, xmin:xmax);
    padded = I_f1;

    I_if1 = fftshift(ifft2(ifftshift(I_f1)));
    If_padded = I_if1;

    xpad = max(xmin, size(I_f,2)-xmax);
    ypad = max(ymin, size(I_f,1)-ymax);

    I_f2 = zeros(size(I_f));
    I_f2(ypad:size(I_f,1)-ypad, xpad:size(I_f,2)-xpad) = I_f(ypad:size(I_f,1)-ypad, xpad:size(I_f,2)-xpad);
    selected = I_f2;

    I_if2 = fftshift(ifft2(ifftshift(I_f2)));
    If_selected = I_if2;

    output = I_if1 .* exp(-1i*angle(I_if2));
end