N = 4;

figure(1);

first_projection_angle=0;
last_projection_angle=180;
delta_theta=0.5;
theta=first_projection_angle:delta_theta:last_projection_angle;

t = tiledlayout(1,8, "TileSpacing", "tight"); title(t,'Comparison of Reconstruction Methods','FontSize', 24); xlabel(t, 'Diff = Difference from the original, IFT = Inverse Fourier Transform, CB = Convolution Backprojection, IRT = Inverse Radon Transform', 'FontSize', 18)
t0 = tiledlayout(t, N,1, "TileSpacing", "tight"); t0.Layout.Tile = 1; title(t0,'Original', 'FontSize', 20);
t1 = tiledlayout(t, N,1, "TileSpacing", "tight"); t1.Layout.Tile = 2; title(t1,'Sinogram', 'FontSize', 20);
t2 = tiledlayout(t, N,1, "TileSpacing", "tight"); t2.Layout.Tile = 3; title(t2,'IFT', 'FontSize', 20);
t3 = tiledlayout(t, N,1, "TileSpacing", "tight"); t3.Layout.Tile = 4; title(t3,'IFT Diff', 'FontSize', 20);
t4 = tiledlayout(t, N,1, "TileSpacing", "tight"); t4.Layout.Tile = 5; title(t4,'CB', 'FontSize', 20);
t5 = tiledlayout(t, N,1, "TileSpacing", "tight"); t5.Layout.Tile = 6; title(t5,'CB Diff', 'FontSize', 20);
t6 = tiledlayout(t, N,1, "TileSpacing", "tight"); t6.Layout.Tile = 7; title(t6,'IRT', 'FontSize', 20);
t7 = tiledlayout(t, N,1, "TileSpacing", "tight"); t7.Layout.Tile = 8; title(t7,'IRT Diff', 'FontSize', 20);

for i = 1:N

    I = imread(sprintf("sample_images/c%d.jpg",i));
    if size(I,3)==3
        I = rgb2gray(I);
    end

    ax=nexttile(t0); imagesc(I); axis('off'); colormap(ax, "gray"); pbaspect(ax,[1 1 1]);

    [sg,xp]=radon(I,theta);

    ax=nexttile(t1); imagesc(sg); axis('off'); colormap(ax, "parula"); pbaspect(ax,[1 1 1]);

    img_ift = inverseFourierReconstruction(sg, xp, theta);
    ax=nexttile(t2); imagesc(img_ift); axis('off'); colormap(ax,'gray'); pbaspect(ax,[1 1 1]);
    ax=nexttile(t3); imagesc(img_ift(2:end-1,2:end-1)-double(I),[-256 256]); axis('off'); colormap(ax,'parula'); pbaspect(ax,[1 1 1]);

    img_conv = convolutionBackprojection(sg, xp, theta, "ramp");
    ax=nexttile(t4); imagesc(img_conv); axis('off'); colormap(ax,'gray'); pbaspect(ax,[1 1 1]);
    ax=nexttile(t5); imagesc(img_conv(2:end-1,2:end-1)-double(I),[-256 256]); axis('off'); colormap(ax,'parula'); pbaspect(ax,[1 1 1]);
    
    img_invrad = iradon(sg,theta);
    ax=nexttile(t6); imagesc(img_invrad); axis('off'); colormap(ax,'gray'); pbaspect(ax,[1 1 1]);
    ax=nexttile(t7); imagesc(img_invrad(2:end-1,2:end-1)-double(I),[-256 256]); axis('off'); colormap(ax,'parula'); pbaspect(ax,[1 1 1]);
end