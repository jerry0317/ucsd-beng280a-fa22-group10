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

%% Construct c(l)
% Create a meshgrid for the final image
[nd, nt] = size(sg);
iw = 2 * floor(nd / (2 * sqrt(2)));
hfiw = iw / 2;
[posX, posY] = meshgrid((1:iw) - hfiw);
w = abs(xp .* (2 / nd));
figure(3); plot(xp, w, 'LineWidth', 2); title('c(l) with ramp filter'); xlabel('linear displacement - l'); ylabel('c(l)'); set(gcf, 'Position',  [100, 100, 450, 400]);

%% IFT c(l)
% Perform convolution of c(l) with the sinogram
c = ifftshift(ifft(fftshift(w),[],1));

figure(4); plot(xp, real(c), 'LineWidth', 2); title('Inverse FT of c(l)'); xlabel('k'); axis('tight'); xlim([-50,50]); ylabel('F^-1[c(l)](k)'); set(gcf, 'Position',  [100, 100, 450, 400]);

%% Convolve c(l) with Sinogram
sgc = convn(sg, c, 'same');
figure(5); imagesc(abs(sgc)); colorbar; title('c(l) * g(l,theta) (convolution)'); axis('square'); xlabel('projection angle theta'); ylabel('linear displacement - l'); pbaspect([1 1 1]); set(gcf, 'Position',  [100, 100, 450, 400]);

%% Backprojection
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
img_fbpr = griddata(xx, yy, img_fbp, posX, posY);

% Take the magnitude to get the final image
imga = abs(img_fbpr);

figure(6); imagesc(imga); colormap('gray'); colorbar; title('Perform Backprojection to get final image'); pbaspect([1 1 1]); set(gcf, 'Position',  [100, 100, 450, 400]);