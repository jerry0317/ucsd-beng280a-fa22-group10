%% Load any RGB Image to Grayscale
I = imread('sample_images/c1.jpg');
I = rgb2gray(I);

figure(1); imagesc(I);title('original image'); axis('equal'); colormap('gray');

%% Projection Angle
first_projection_angle=0;
last_projection_angle=180;
delta_theta=0.5;
theta=first_projection_angle:delta_theta:last_projection_angle;
[sg_0,xp]=radon(I,theta);

%% Zero Range
zero_ranges_x = {0,395:405,395:405,1:1249,700:800,300:350};
zero_ranges_y = {0,170:180,1:361,170:180,210:230,110:150};
N_zero_ranges = size(zero_ranges_x, 2);

%% Plot TileLayout
figure(2);

t = tiledlayout(4,1, "TileSpacing", "tight"); title(t,'Effect of Zero Pixels in Sinogram','FontSize', 24); xlabel(t, 'IFT = Inverse Fourier Transform, CB = Convolution Backprojection, IRT = Inverse Radon Transform', 'FontSize', 18)
t0 = tiledlayout(t, 1, N_zero_ranges, "TileSpacing", "tight"); t0.Layout.Tile = 1; ylabel(t0,'Sinogram', 'FontSize', 20);
t1 = tiledlayout(t, 1, N_zero_ranges, "TileSpacing", "tight"); t1.Layout.Tile = 2; ylabel(t1,'IFT', 'FontSize', 20);
t2 = tiledlayout(t, 1, N_zero_ranges, "TileSpacing", "tight"); t2.Layout.Tile = 3; ylabel(t2,'CB', 'FontSize', 20);
t3 = tiledlayout(t, 1, N_zero_ranges, "TileSpacing", "tight"); t3.Layout.Tile = 4; ylabel(t3,'IRT', 'FontSize', 20);


for i=1:N_zero_ranges
    if zero_ranges_x{i} == 0
        kx = [];
        ky = [];
    else
        kx = zero_ranges_x{i};
        ky = zero_ranges_y{i};
    end

    sg = sg_0;
    sg(kx, ky) = 0;

    ax=nexttile(t0); imagesc(sg); axis('off'); colormap(ax, "parula"); pbaspect(ax,[1 1 1]);

    img_ift = inverseFourierReconstruction(sg, xp, theta);
    ax=nexttile(t1); imagesc(img_ift); axis('off'); colormap(ax,'gray'); pbaspect(ax,[1 1 1]);

    img_conv = convolutionBackprojection(sg, xp, theta, "ramp");
    ax=nexttile(t2); imagesc(img_conv); axis('off'); colormap(ax,'gray'); pbaspect(ax,[1 1 1]);
    
    img_invrad = iradon(sg,theta);
    ax=nexttile(t3); imagesc(img_invrad); axis('off'); colormap(ax,'gray'); pbaspect(ax,[1 1 1]);
end