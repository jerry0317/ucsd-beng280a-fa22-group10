function imga = convolutionBackprojection(sg, xp, theta, filter)
    % Requires Image Processing Toolbox for imrotate.
    arguments
        sg % Input sinogram. Displacement along dimension 1 and angle along dimension 2.
        xp = (1:size(sg, 1)) - (size(sg, 1) / 2); % (Optional) Displacement
        theta = linspace(0, 180, size(sg, 2)); % (Optional) Angle
        filter = "ramp"; % (Optional) Windowing filter. Select from ramp, hamming, hanning.
    end

    % Create a meshgrid for the final image
    [nd, nt] = size(sg);
    iw = 2 * floor(nd / (2 * sqrt(2)));
    hfiw = iw / 2;
    [posX, posY] = meshgrid((1:iw) - hfiw);

    % Consturct c(l) for convolution
    switch filter
        case 'ramp'
            w = abs(xp .* (2 / nd));
        case 'hamming'
            w = 0.54 - 0.46 * cos(2 * pi .* (xp .* (2 / nd)));
            w = w .* abs(xp .* (2 / nd));
        case 'hanning'
            w = 0.5 - 0.5 * cos(2 * pi .* (xp .* (2 / nd)));
            w = w .* abs(xp .* (2 / nd));
        otherwise
            fprintf("Wrong Filter");
    end

    % Perform convolution of c(l) with the sinogram
    c = ifftshift(ifft(fftshift(w),[],1));
    sgc = convn(sg, c, 'same');

    % Create a Cartesian grid for backprojection
    img_fbp = zeros(nd);
    
    % Perform backprojection
    for i = 1:nt
        t = theta(i);
        projed = repmat(sgc(:,i), 1, nd).';
        projedr = imrotate(projed, t, 'bilinear', 'crop');
        img_fbp = img_fbp + (projedr / nt);
    end

    % Find the actual Cartesian coordinates for the points (shift to center)
    [xx, yy] = meshgrid((1:nd) - (nd / 2));

    % Interpolate the points to a smaller canvas (the original image size)
    img_fbpr = interp2(xx, yy, img_fbp, posX, posY);

    % Take the magnitude to get the final image
    imga = abs(img_fbpr);
end
