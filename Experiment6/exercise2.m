clc; clear; close all; 
N=100000; %Number of data bits to send over the channel 
EbN0dB=-6:2:12; 
N=N+rem((4-rem(N,4)),4); %add additional bits to the data to make the length multiple of 4 
% one 16-PSK symbol contains 4 binary bits 
x=rand(1,N)>=0.5;%Generate random 1's and 0's as data; 
%Club 4 bits together and gray code it individually 
inputSymBin=reshape(x,4,N/4)'; 
g=bin2gray(inputSymBin); 
%Convert each Gray coded symbols to decimal value this is to ease the process of mapping based on 
%arrayindex 
b=bin2dec(num2str(g,'%-1d'))'; 
%16-PSK Constellation Mapper 
%16-PSK mapping Table 
M=16; %Number of Constellation points M=2^k for 16-PSK k=4 
x = (0:M-1)';
map=qammod(x,M);
s=map(b(:)+1,1)+1i*map(b(:)+1,1); 
%Simulation for each Eb/N0 value 
Rm=log2(M); %Rm=log2(M) for 16-PSK M=16 
Rc=1; %Rc = code rate for a coded system. Since no coding is used Rc=1 
simulatedBER = zeros(1,length(EbN0dB)); 
theoreticalBER = zeros(1,length(EbN0dB)); 
count=1; 
figure; 
for i=EbN0dB
%-------------------------------------------
%Channel Noise for various Eb/N0 
%-------------------------------------------
%Adding noise with variance according to the required Eb/N0 
EbN0 = 10.^(i/10); %Converting Eb/N0 dB value to linear scale 
noiseSigma = sqrt(2)*sqrt(1./(2*Rm*Rc*EbN0)); %Standard deviation for AWGN Noise 
%Creating a complex noise for adding with 16-PSK s signal 
%Noise is complex since 16-PSK is in complex representation 
n = noiseSigma*(randn(1,length(s))+1i*randn(1,length(s)))'; 
y = s + n; 
plot(real(y),imag(y),'r*');hold on;
plot(real(s),imag(s),'ko','MarkerFaceColor','g','MarkerSize',7);hold off; 
title(['Constellation plots - ideal 16-PSK (green) Vs Noisy y signal for EbN0dB =',num2str(i),'dB']); 
pause; 
%Demodulation 
%Find the signal points from MAP table using minimum Euclidean distance 
demodSymbols = zeros(1,length(y)); 
for j=1:length(y) 
[minVal,minindex]=min(sqrt((real(y(j))-map(:,1)).^2+(imag(y(j))-map(:,2)).^2)); 
demodSymbols(j)=minindex-1; 
end 
demodBits=dec2bin(demodSymbols)-'0'; %Dec to binary vector 
xBar=gray2bin(demodBits)'; %gray to binary 
xBar=xBar(:)'; 
bitErrors=sum(sum(xor(x,xBar))); 
simulatedBER(count) = log10(bitErrors/N); 
theoreticalBER(count) = log10(1/3*erfc(sqrt(EbN0*3)*sin(pi/8))); 
count=count+1; 
end 
figure; 
plot(EbN0dB,theoreticalBER,'r-*');hold on; 
plot(EbN0dB,simulatedBER,'k-o'); 
title('BER Vs Eb/N0 (dB) for 16-PSK');legend('Theoretical','Simulated');grid on; 
xlabel('Eb/N0 dB'); 
ylabel('BER - Bit Error Rate'); 
grid on;



function [binaryCoded]=gray2bin(grayInput) 
[rows,cols]=size(grayInput);
binaryCoded=zeros(rows,cols); 
for i=1:rows 
binaryCoded(i,1)=grayInput(i,1); 
for j=2:cols 
binaryCoded(i,j)=xor(binaryCoded(i,j-1),grayInput(i,j)); 
end 
end 
end

function [grayCoded]=bin2gray(binaryInput) 
[rows,cols]=size(binaryInput); 
grayCoded=zeros(rows,cols); 
for i=1:rows 
grayCoded(i,:)=[binaryInput(i,1) xor(binaryInput(i,2:cols),binaryInput(i,1:cols-1))]; 
end 
end
