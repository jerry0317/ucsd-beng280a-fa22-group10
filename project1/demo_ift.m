%% Load Image
I = imread('sample_images/c2.jpg');
if size(I,3)==3
    I = rgb2gray(I);
end

figure(1); imagesc(I);title('original image'); axis('equal'); colormap('gray'); colorbar; pbaspect([1 1 1]); set(gcf, 'Position',  [100, 100, 450, 400]);

%% Sinogram
first_projection_angle=0;
last_projection_angle=180;
delta_theta=0.5;
theta=first_projection_angle:delta_theta:last_projection_angle;
[sg,xp]=radon(I,theta);
figure(2); imagesc(sg); colorbar; title('projections g(l,theta) - Radon Transform'); axis('square'); xlabel('projection angle theta'); ylabel('linear displacement - l'); pbaspect([1 1 1]); set(gcf, 'Position',  [100, 100, 450, 400]);

%% 1D FT
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

figure(3); imagesc(abs(gf)); colorbar; title('1D FT for each projection'); pbaspect([1 1 1]); set(gcf, 'Position',  [100, 100, 450, 400]);

%% Polar Interpolated to Cartesian
% Interpolate the scattered Fourier space points to the Cartesian grid
img_fbp = griddata(X,Y,gf,posX,-posY);

figure(4); imagesc(abs(img_fbp)); colorbar; title('1D FT for each col., interpolated to Cartesian'); pbaspect([1 1 1]); set(gcf, 'Position',  [100, 100, 450, 400]);

%% Inverse FT to spatial space
img_fbpr = ifftshift(ifft2(fftshift(img_fbp)));

figure(5); imagesc(abs(img_fbpr)); colormap('gray'); colorbar; title('Inverse 2D FT from k-space to x-space'); pbaspect([1 1 1]); set(gcf, 'Position',  [100, 100, 450, 400]);

%% Select the relavent region
% Interpolate back to the original image scale (effectly zoom in by sqrt(2))
[posXa, posYa] = meshgrid(((1:iw) - hfiw) / sqrt(2));
img_fbpra = griddata(posX,posY,img_fbpr,posXa,posYa);

% Take the magnitude to get the final image
imga = abs(img_fbpra);

figure(6); imagesc(imga); colormap('gray'); colorbar; title('Zoom in to select only the relavent region'); pbaspect([1 1 1]); set(gcf, 'Position',  [100, 100, 450, 400]);