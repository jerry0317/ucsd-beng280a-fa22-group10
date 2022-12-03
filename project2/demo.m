I = imread('sample_images/c5.png');
if size(I,3)==3
    I = rgb2gray(I);
end

figure(1); imagesc(I);title('Original Image'); axis('square'); colormap('gray'); colorbar;

I_f = ifftshift(fft2(fftshift(I)));
figure(2); imagesc(abs(I_f)); axis('square'); colormap('jet'); colorbar; set(gca, 'ColorScale', 'log'); title("FT of Original Image (k-image)");

%% 
nx = size(I_f,2);
ny = size(I_f,1);
YHOVER = 64;
XHOVER = 48;

%% Zero Padding

[I_if1, I_f1] = pifft_zero_padding(I_f, 1, nx-XHOVER, 1, ny-YHOVER); 
figure(3); imagesc(abs(I_f1)); axis('square'); colormap('jet'); colorbar; set(gca, 'ColorScale', 'log'); title("Partial k-image");

figure(4); imagesc(abs(I_if1)); axis('square'); colormap('gray'); colorbar; title("IFT of Zero Padding k-image");

figure(5); imagesc(abs(abs(I_if1)-double(I))); axis('square'); colormap('jet'); colorbar; title("Difference to GT");

disp("GT MSE: " + immse(abs(I_if1),double(I)));

%% Zero Padding Pixels vs IMMSE
max_YHOVER = 120;
mse_list = zeros(1, max_YHOVER);

for yh=1:max_YHOVER
    [I_if1, ~] = pifft_zero_padding(I_f, 1, nx-XHOVER, 1, ny-yh); 
    mse_list(yh) = immse(abs(I_if1),double(I));
end

figure(6); plot(1:max_YHOVER, mse_list, "LineWidth", 2); xlabel("Removed Pixels"); ylabel("GT MSE"); title("Removed Pixels vs. GT MSE");

%% Phase Correction
[Ip, Ipp, Ips, If_pp, If_ps] = pifft_phase_correction(I_f, 1, nx-XHOVER, 1, ny-YHOVER); 
I_if = fftshift(ifft2(ifftshift(I_f))); % GT Phase

figure(7); imagesc(abs(Ips)); axis('square'); colormap('jet'); colorbar; set(gca, 'ColorScale', 'log'); title("Selected Symmetric Region of k-image");

figure(8); imagesc(angle(I_if),[-pi, pi]); axis('square'); colormap('jet'); colorbar; title("Phase of GT k-image");

figure(9); imagesc(angle(If_ps),[-pi, pi]); axis('square'); colormap('jet'); colorbar; title("Phase of selected k-image");

figure(10); imagesc(abs(angle(If_ps)-angle(I_if)),[0, pi]); axis('square'); colormap('jet'); colorbar; title("Difference to GT Phase");

%% Conjugate Synthesis
[Ic, Ikc] = pifft_conjugate_synthesis(Ip, 1, nx-XHOVER, 1, ny-YHOVER); 
I_fp = ifftshift(fft2(fftshift(Ip)));

figure(11); imagesc(abs(I_fp)); axis('square'); colormap('jet'); colorbar; set(gca, 'ColorScale', 'log'); title("Phase corrected k-image");

figure(12); imagesc(abs(Ikc)); axis('square'); colormap('jet'); colorbar; set(gca, 'ColorScale', 'log'); title("Complete k-image w/ conjugate symmetry");

figure(13); imagesc(abs(Ic)); axis('square'); colormap('gray'); colorbar; title("IFT of Conjugate Synthesis k-image");

figure(14); imagesc(abs(abs(Ic)-double(I))); axis('square'); colormap('jet'); colorbar; title("Difference to GT");

disp("GT MSE: " + immse(abs(Ic),double(I)));

%% Homodyne Reconstruction
[Ih,Ihs,hW,Ihw,Ihfs,Ihfw,hWx,hWy] = pifft_homodyne_reconstruction(I_f,1, nx-XHOVER, 1, ny-YHOVER, "step", true, 0.5); 

figure(15); imagesc(abs(I_f1)); axis('square'); colormap('jet'); colorbar; set(gca, 'ColorScale', 'log'); title("Partial k-image");

figure(22); imagesc(hW); axis('square'); colormap('jet'); colorbar; title("Weight function");

figure(23); imagesc(abs(Ihw)); axis('square'); colormap('jet'); colorbar; set(gca, 'ColorScale', 'log'); title("Weighted k-image");

figure(24); imagesc(abs(Ihfw)); axis('square'); colormap('gray'); colorbar; title("IFT of Weighted k-image");

figure(25); imagesc(real(Ih)); axis('square'); colormap('gray'); colorbar; title("Output w/ phase correction");

figure(26); imagesc(abs(real(Ih)-double(I))); axis('square'); colormap('jet'); colorbar; title("Difference to GT");

figure(27); plot(1:nx, hWx, "LineWidth", 2); xlabel("Pixel"); ylabel("Weight"); xlim tight;title("Step Weight function")

disp("GT MSE: " + immse(real(Ih),double(I)));

%% Homodyne vs Smoothness
smt = 0.02:0.02:15;

step_mse_list = zeros(1, length(smt));
linear_mse_list = zeros(1, length(smt));

for i=1:length(smt)
    Ih_step = pifft_homodyne_reconstruction(I_f,1, nx-XHOVER, 1, ny-YHOVER, "step", true, smt(i)); 
    step_mse_list(i) = immse(real(Ih_step),double(I));
    Ih_linear = pifft_homodyne_reconstruction(I_f,1, nx-XHOVER, 1, ny-YHOVER, "linear", true, smt(i)); 
    linear_mse_list(i) = immse(real(Ih_linear),double(I));
end

figure(28); plot(smt, step_mse_list, "LineWidth", 2); hold on; plot(smt, linear_mse_list, "LineWidth", 2); hold off; legend("Step function", "Linear function"); xlabel("Smoothness"); xlim tight; ylabel("MSE to GT"); title("Smoothness vs MSE to GT");

%% POCS
XHOVER = 0;
YHOVER = 64;
[I_if1, I_f1] = pifft_zero_padding(I_f, 1, nx-XHOVER, 1, ny-YHOVER); 
figure(3); imagesc(abs(I_f1)); axis('square'); colormap('jet'); colorbar; set(gca, 'ColorScale', 'log'); title("Partial k-image");
[Ipocs, npocs, dpocs, mpocs] = pifft_POCS(I_f, 1, nx-XHOVER, 1, ny-YHOVER, 1e-4, I);
figure(29); imagesc(abs(Ipocs)); axis('square'); colormap('gray'); colorbar; title("POCS output");
figure(30); imagesc(abs(abs(Ipocs)-double(I))); axis('square'); colormap('jet'); colorbar;  title("Difference to GT");
figure(31); semilogy(1:npocs, dpocs, "LineWidth", 1.5); ylabel("Inter-step MSE"); xlabel("# of POCS Iterations");
figure(32); semilogy(1:npocs, mpocs, "LineWidth", 1.5); ylabel("Ground Truth MSE"); xlabel("# of POCS Iterations");
disp("GT MSE: " + immse(abs(Ipocs),double(I)));

