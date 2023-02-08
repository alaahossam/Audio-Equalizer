load handel.mat
disp('Welcome to the sound equalizer app')

% taking the file path, name and extinsion and validate the extension
filepathname = input('please enter a wav file name : ', 's')
[filepath,name,ext] = fileparts(filepathname)
while ~strcmp(ext, '.wav')
    filepathname = input('please enter a wav file name : ', 's')
    [filepath,name,ext] = fileparts(filepathname)
end

% reading the audio file
[input_signal, Fs] = audioread(filepathname);
sound(input_signal,Fs);

% taking the sample rate with validation must be > 0 
Fs = input('Please Enter sample rate. 48khz recommended : ');
 while ~(isa(Fs,'double')) || Fs < 0
     Fs = input('Please Enter a number for sample rate. 44khz recommended : ');
 end


%taking the length of the signal and generate the time and frequency for x
%axis in plots
leng = length(input_signal);
time = linspace(0, leng/Fs, leng);
fre = linspace(-Fs/2, Fs/2, leng);

%plotting input function in time and frequency
  subplot(2, 1, 1);
  plot (time, input_signal);
  title('input signal in time domain');
  subplot(2, 1, 2);
  plot (fre, abs(fftshift(fft(input_signal))));
  title('input signal in frequency domain');
  
% array of frequencies
b = {'0- 170 Hz', '170- 310 Hz', '310- 600 Hz', '600- 1000 Hz', '1- 3 KHz', '3- 6 KHz', '6-12 KHz', '12-14 KHz', '14-16 KHz'}
frequencies = [0,170,310,600,1000,3000,6000,12000,14000,16000];

%array of gains and getting gain of each frequency from the user and
%validate its value
arrgain = [zeros, 9] ;
for i=1:1:9
    fprintf('Please enter the gain for the frequency : %s', char(b(i)))
    gain = input(' : ');
    while ~isa(gain, 'double') || gain < 0 
    fprintf('Please enter the gain in decibal for the frequency : %s', char(b(i)))
    gain = input(' : ') ;  
    end
    arrgain(i) = gain ;
end

% taking the type of filter with validation must be 1 or 2 (IIR or FIR)
typef = input('Enter the type of Filter : 1-IIR. 2-FIR : ');
while (typef ~= 1) & (typef ~= 2)
    typef = input('Enter the type of Filter : 1-IIR. 2-FIR : ');
end

% definition of numerator and denominator and order of fir and iir
numerator = cell(9, 1); %bt-create empty cells fi matrix be size 9x1
denominator = cell(9, 1);
iirOrder = 3;    
firOrder = iirOrder * 10;%iirOrder*10;
if typef == 1 %IIR
    
  %low pass filter
[numerator{1}, denominator{1}] =  butter(iirOrder,frequencies(2)/(Fs/2));

 %bandpass filters
 for i = 2 : 9
 [numerator{i}, denominator{i}] = butter(iirOrder,([frequencies(i) frequencies(i+1)])/(Fs/2),'bandpass');
 end

 %plotting filters in time and frequency domain
 for i = 1 : 9
     figure;
     freqz(numerator{i}, denominator{i});
 end
 figure;
%  plotting impulse responce of each filter
for i = 1: 9
    subplot(3,3,i);
  impz(numerator{i},denominator{i});  
end
figure;
%  plotting step responce of each filter
for i = 1: 9
   subplot(3,3,i);
  stepz(numerator{i},denominator{i});
end
 figure;
 %  plotting poles and zeros of each filter
 for i = 1: 9   
     subplot(3,3,i);
   pzmap(numerator{i}, denominator{i});
 end 
 
else %FIR
    %low pass filter
      numerator{1} = fir1(firOrder , frequencies(2)/(Fs/2));
      %bandpass filters
  for i = 2 : 9
 numerator{i} = fir1(firOrder, [frequencies(i) frequencies(i+1)]/(Fs/2),'bandpass');
  end
  %plotting filters in time and frequency domain
  for i = 1 : 9
     figure;
     freqz(numerator{i}, 1);
 end
 figure;
 %  plotting impulse responce of each filter
for i = 1: 9
    subplot(3,3,i);
  impz(numerator{i}, 1);  
end
figure;
%  plotting step responce of each filter
for i = 1: 9
   subplot(3,3,i);
  stepz(numerator{i}, 1);
end
 figure;
 %  plotting poles and zeros of each filter
 for i = 1: 9
     subplot(3,3,i);
   zplane(numerator{i},1);
 end 
end

filters = cell(9,1);
output = [];
%filtering input signal with each filter and plotting the output signal in
%time and frequency domain
  for i = 1 : 9
      figure;
      if typef == 1
      filters{i} = filter(numerator{i}, denominator{i}, input_signal);
      else
          filters{i} = filter(numerator{i}, 1, input_signal);
  end
     subplot(2,1,1);
     plot(fre ,abs(fftshift(fft(filters{i}))));
     title('filterd signal in frequency domain');
     subplot(2,1,2);
     plot(time, filters{i});
     title('filtered signal in time domain');
  end
  %containing filtered signals to form the composite signal
  for i = 1 : 9
      
      output = [output 10^(arrgain(i)/20)*filters{i}];
  end
 % plotting composite signal with input signal in time and frequency domain
figure;
subplot(2,1,1);
plot(time, input_signal);
title('Input signal in time domain');
subplot(2,1,2);
plot(time, output);
title('composite signal in time domain');

figure;
subplot(2,1,1);
plot(fre, abs(fftshift(fft(input_signal))));
title('input signal in frequency domain');
subplot(2,1,2);
plot(fre, abs(fftshift(fft(output))));
title('composite signal in frequency domain');

% writing the file
filename2 = input('Enter the name of the file: ','s');
audiowrite(filename2, output, Fs);
%audiowrite('filename12.wav', output,Fs);

