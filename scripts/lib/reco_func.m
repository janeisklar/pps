function reco_func(writefile_fid, dim_readout, dim_pe)

global magnitude_image phase_image 

%read the k-space data from the .img file
fp_fid=fopen(writefile_fid, 'r');
K = fread(fp_fid, [2*dim_readout dim_pe], 'float32');
fclose(fp_fid);

%crass for the moment; assume dim_readout is 2^n, and that if 
%dim_pe != dim_readout, then padding to dim_pe_new = dim_readout will solve
%problems of asymmetric matrix

dim_pe_new=dim_readout;

%zero fill to make a symmetric 2^n matrix
real_K=zeros(dim_readout);
im_K=zeros(dim_readout);
sf=int16((dim_readout-dim_pe)/2)+1;
ef=dim_pe+int16((dim_readout-dim_pe)/2);
%half the number of lines to pack (half before, half after k-space data)
no_lines_to_pack=dim_pe_new-dim_pe;
nlph=int16(no_lines_to_pack/2);


for i=1:2*dim_readout
    %odd lines are real
    j=int16(i/2);
   if mod(i,2)==1
      real_K(j,sf:ef)=K(i,:);
   end
    %even lines are imaginary   
   if mod(i,2)==0
      im_K(j,sf:ef)=K(i,:);
   end
end

%   shift through half a FOV in both directions to put echo close to origin
%   will need to change this if echo position is not at 50% through the
%   acquisition
shift_readout=dim_readout/2;
shift_pe=dim_pe_new/2;

real_K = circshift(real_K, [ 1 - shift_readout, 1 - shift_pe]);
im_K = circshift(im_K, [ 1 - shift_readout, 1 - shift_pe]);

%   now create the complex fft data
complex_K=complex(real_K,im_K);

%   do the 2d fft, reconstructing to a symmetric 2^n matrix
image=fft2(complex_K, dim_readout, dim_pe_new);

%   get the real and imaginary parts
real_image=real(image);
imaginary_image=imag(image);

image=circshift(image, [shift_readout shift_pe]);

%and flip to the right orientation

image=flipdim(flipdim(image,2),1);

%make absolute and phase images

magnitude_image=abs(image);
phase_image=atan2(imag(image),real(image));

