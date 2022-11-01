warning('off','all');

I = imread('sample_images/c1.jpg');
if size(I,3)==3
    I = rgb2gray(I);
end

disp("dim: " + size(I,1));

first_projection_angle=0;
last_projection_angle=180;
delta_theta=0.5;
theta=first_projection_angle:delta_theta:last_projection_angle;
[sg,xp]=radon(I,theta);

N = 100;

tic;
f = waitbar(0, "Running IFT");
for i=1:N
    img_ift = inverseFourierReconstruction(sg, xp, theta);
    waitbar(i/N,f);
end
close(f);
toc;

tic;
f = waitbar(0, "Running CB");
for i=1:N
    img_conv = convolutionBackprojection(sg, xp, theta, "ramp");
    waitbar(i/N,f);
end
close(f);
toc;

tic;
f = waitbar(0, "Running IRT");
for i=1:N
    img_invrad = iradon(sg,theta);
    waitbar(i/N,f);
end
close(f);
toc;