%% Load any RGB Image to Grayscale
I = imread('sample_images/c1.jpg');
I = rgb2gray(I);

figure(1); imagesc(I);title('original image'); axis('equal'); colormap('gray');

%% Use Radon Transform to Generate Sinogram
first_projection_angle=0;
last_projection_angle=180;
delta_theta=2.0;
data_peak_to_noise_ratio=10.0;
theta=first_projection_angle:delta_theta:last_projection_angle;
[sg,xp]=radon(I,theta);
figure(2); imagesc(sg); title('projections g(l,theta) - Radon Transform'); axis('square'); xlabel('projection angle theta'); ylabel('linear displacement - l');

%% Perform Inverse Fourier Reconstruction, Convolution Backprojection, and Inverse Radon Transform
img_ift = inverseFourierReconstruction(sg, xp, theta);
figure(3); imagesc(img_ift); title('Inverse Fourier Reconstruction'); axis('equal'); colormap('gray');

img_conv = convolutionBackprojection(sg, xp, theta, "ramp");
figure(4); imagesc(img_conv); title('Convolution Backprojection'); axis('equal'); colormap('gray');

img_invrad = iradon(sg,theta);
figure(5); imagesc(img_invrad); title('Inverse Radon Transform'); axis('equal'); colormap('gray'); 