clc, clear, close all
%————————choose coin main function—————————
dirname = 'data';
files = dir(fullfile(dirname, '*.xlsx'));
N = length(files);
RM = zeros(N, 2);
tsn = 0;

for i = 1:N
    filename = fullfile(dirname, files(i).name);
    [a, b] = coinFactor(filename);
    RM(1,:) = [a, b];
end

T = 1: N;
%————————————decision function——————————————
F = RM(:,1) - 0.5 * RM(:,2);
[maxF, maxIDF] = max(F);



