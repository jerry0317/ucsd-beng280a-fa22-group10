%% Load any RGB Image to Grayscale
I = imread('sample_images/c1.jpg');
I = rgb2gray(I);

figure(1); imagesc(I);title('original image'); axis('equal'); colormap('gray');

%% Delta_thetas
% delta_thetas = [0.1 0.5 1.0 2.0 4.0];
delta_thetas = [10.0 5.0 2.0 1.0 0.5 0.1];
N_delta_thetas = size(delta_thetas, 2);

first_projection_angle=0;
last_projection_angle=180;

%% Plot TileLayout
figure(2);

t = tiledlayout(4,1, "TileSpacing", "tight"); title(t,'Effect of dθ','FontSize', 24); xlabel(t, 'IFT = Inverse Fourier Transform, CB = Convolution Backprojection, IRT = Inverse Radon Transform', 'FontSize', 18)
t0 = tiledlayout(t, 1, N_delta_thetas, "TileSpacing", "tight"); t0.Layout.Tile = 1; ylabel(t0,'Sinogram', 'FontSize', 20);
t1 = tiledlayout(t, 1, N_delta_thetas, "TileSpacing", "tight"); t1.Layout.Tile = 2; ylabel(t1,'IFT', 'FontSize', 20);
t2 = tiledlayout(t, 1, N_delta_thetas, "TileSpacing", "tight"); t2.Layout.Tile = 3; ylabel(t2,'CB', 'FontSize', 20);
t3 = tiledlayout(t, 1, N_delta_thetas, "TileSpacing", "tight"); t3.Layout.Tile = 4; ylabel(t3,'IRT', 'FontSize', 20);


for i=1:N_delta_thetas
    delta_theta=delta_thetas(i);
    theta=first_projection_angle:delta_theta:last_projection_angle;
    [sg,xp]=radon(I,theta);
    ax=nexttile(t0); imagesc(sg); axis('off'); colormap(ax, "parula"); pbaspect(ax,[1 1 1]); title("dθ="+delta_theta+"°", 'FontSize', 20);

    img_ift = inverseFourierReconstruction(sg, xp, theta);
    ax=nexttile(t1); imagesc(img_ift); axis('off'); colormap(ax,'gray'); pbaspect(ax,[1 1 1]);

    img_conv = convolutionBackprojection(sg, xp, theta, "ramp");
    ax=nexttile(t2); imagesc(img_conv); axis('off'); colormap(ax,'gray'); pbaspect(ax,[1 1 1]);
    
    img_invrad = iradon(sg,theta);
    ax=nexttile(t3); imagesc(img_invrad); axis('off'); colormap(ax,'gray'); pbaspect(ax,[1 1 1]);
end