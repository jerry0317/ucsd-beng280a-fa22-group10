function [output,padded] = pifft_zero_padding(I_f, xmin, xmax, ymin, ymax)
    arguments
        I_f; % Input k-image
        xmin = 1; 
        xmax = -1;
        ymin = 1;
        ymax = -1;
    end

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
    output = I_if1;
end