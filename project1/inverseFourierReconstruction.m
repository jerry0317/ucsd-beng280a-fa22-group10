function imga = inverseFourierReconstruction(sg, xp, theta)
    arguments
        sg % Input sinogram. Displacement along dimension 1 and angle along dimension 2.
        xp = (1:size(sg, 1)) - (size(sg, 1) / 2); % (Optional) Displacement
        theta = linspace(0, 180, size(sg, 2)); % (Optional) Angle
    end

    % Create a meshgrid for the final image
    nd = size(sg, 1);
    iw = 2 * floor(nd / (2 * sqrt(2)));
    hfiw = iw / 2;
    [posX, posY] = meshgrid((1:iw) - hfiw);

    % Find the actual Cartesian coordinate for each point in the sinogram
    [T, R] = meshgrid(theta, xp);
    [X, Y] = pol2cart(deg2rad(T), R);

    % 1-D Fourier Transform the sinogram along each column (for each projection)
    gf = ifftshift(fft(fftshift(sg), [], 1));

    % Interpolate the scattered Fourier space points to the Cartesian grid
    img_fbp = griddata(X,Y,gf,posX,-posY);

    % Inverse Fourier Transform the Cartesian FT Grid to get the Cartesian grid in the spatial space.
    img_fbpr = ifftshift(ifft2(fftshift(img_fbp)));

    % Interpolate back to the original image scale (effectly zoom in by sqrt(2))
    [posXa, posYa] = meshgrid(((1:iw) - hfiw) / sqrt(2));
    img_fbpra = griddata(posX,posY,img_fbpr,posXa,posYa);

    % Take the magnitude to get the final image
    imga = abs(img_fbpra);
end