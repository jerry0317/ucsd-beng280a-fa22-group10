il=5:10;
ZeroPadding = zeros(length(il),1);
ConjugateSynthesis = zeros(length(il),1);
HomodyneRecon = zeros(length(il),1);
POCS = zeros(length(il),1);

nx = 256;
ny = 256;
YHOVER = 64;
XHOVER = 0;

for i=1:length(il)
    I = imread("sample_images/c"+num2str(il(i))+".png");
    I_f = ifftshift(fft2(fftshift(I)));
    I_if1 = pifft_zero_padding(I_f, 1, nx-XHOVER, 1, ny-YHOVER); 
    ZeroPadding(i) = immse(abs(I_if1),double(I));

    Ip = pifft_phase_correction(I_f, 1, nx-XHOVER, 1, ny-YHOVER); 
    Ic = pifft_conjugate_synthesis(Ip, 1, nx-XHOVER, 1, ny-YHOVER); 
    ConjugateSynthesis(i) = immse(abs(Ic),double(I));

    Ih = pifft_homodyne_reconstruction(I_f,1, nx-XHOVER, 1, ny-YHOVER, "step", true, 0.5); 
    HomodyneRecon(i) = immse(real(Ih),double(I));

    Ipocs = pifft_POCS(I_f, 1, nx-XHOVER, 1, ny-YHOVER, 1e-4);
    POCS(i) = immse(abs(Ipocs),double(I));
end

outtable = table(il.', ZeroPadding, ConjugateSynthesis, HomodyneRecon, POCS);
outtableT = rows2vars(outtable);