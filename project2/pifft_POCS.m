function [output, n_iters, diff_iters, immse_iters] = pifft_POCS(I_f, xmin, xmax, ymin, ymax, pocs_threshold, I)
    arguments
        I_f; % Input k-image
        xmin = 1; 
        xmax = -1;
        ymin = 1;
        ymax = -1;
        pocs_threshold = 1e-2;
        I = [];
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

    I_if1 = fftshift(ifft2(ifftshift(I_f1)));

    xpad = max(xmin, size(I_f,2)-xmax);
    ypad = max(ymin, size(I_f,1)-ymax);

    I_f2 = zeros(size(I_f));
    I_f2(ypad:size(I_f,1)-ypad+1, xpad:size(I_f,2)-xpad+1) = I_f(ypad:size(I_f,1)-ypad+1, xpad:size(I_f,2)-xpad+1);

    I_if2 = fftshift(ifft2(ifftshift(I_f2)));

    im_init = abs(I_if1) .* exp(1i*angle(I_if2));

    tmp_k = ifftshift(fft2(fftshift(im_init)));
    diff_im = pocs_threshold + 1;

    n_iters = 0;
    diff_iters = [];
    immse_iters = [];

    I_l = zeros(size(I_f));
    I_l(ymin:ymax, xmin:xmax) = 1; % Remaining part (non-zero part)
    I_l = logical(I_l);

    while(abs(diff_im) > pocs_threshold)
        tmp_k(I_l) = I_f1(I_l);
        tmp_im = fftshift(ifft2(ifftshift(tmp_k)));
        tmp_im = abs(tmp_im) .* exp(1i*angle(I_if2));
        tmp_k = ifftshift(fft2(fftshift(tmp_im)));
        
        diff_im = abs(tmp_im - im_init);
        diff_im = sum(diff_im(:).^2);

        im_init = tmp_im;
        n_iters = n_iters + 1;
        diff_iters(n_iters) = diff_im;
        if ~isempty(I)
            immse_iters(n_iters) = immse(abs(tmp_im),double(I));
        end
    end
    
    output = tmp_im;
end