function [output, conjsyn] = pifft_conjugate_synthesis(Ip, xmin, xmax, ymin, ymax)
    arguments
        Ip; % Input Phase Corrected Cartesian Image
        xmin = 1; 
        xmax = -1;
        ymin = 1;
        ymax = -1;
    end
    I_f = ifftshift(fft2(fftshift(Ip)));

    assert(all(mod(size(I_f),2) == [0,0]));

    if xmax == -1
        xmax = size(I_f,2);
    end

    if ymax == -1
        ymax = size(I_f,1);
    end

    xpad = max(xmin, size(I_f,2)-xmax);
    ypad = max(ymin, size(I_f,1)-ymax);

    I_f2 = I_f;

    if xmin > size(I_f,2)-xmax
        I_f2(:,1:xpad) = rot90(conj(I_f(:,size(I_f,2)-xpad+1:end)),2);
    else
        I_f2(:,size(I_f,2)-xpad+1:end) = rot90(conj(I_f(:,1:xpad)),2);
    end

    if ymin > size(I_f,1)-ymax
        I_f2(1:ypad,:) = rot90(conj(I_f(size(I_f,1)-ypad+1:end,:)),2);
    else
        I_f2(size(I_f,1)-ypad+1:end,:) = rot90(conj(I_f(1:ypad,:)),2);
    end

    conjsyn = I_f2;

    I_if2 = fftshift(ifft2(ifftshift(I_f2)));
    output = I_if2;

end