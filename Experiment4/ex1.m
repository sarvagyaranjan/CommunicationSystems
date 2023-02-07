y = sin(x); 
x = 0:0.1:100; 

awgnchan = comm.AWGNChannel;
awgn_out = awgnchan(y);
plot(awgn_out);
legend('Sine wave passed through AWGN')
xlabel("Time"); 
ylabel("Amplitude");
