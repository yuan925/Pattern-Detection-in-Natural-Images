function StatsOut = computeSceneSimilarityAmplitude(imIn, tarIn, wWin, sampleCoords)
%%COMPUTESCENCESIMILARITYAMPLITUDE Computes the similarity of the image to a target in the Fourier domain
%
% Example:
%   StatsOut = COMPUTESCENESIMILARITYAMPLITUDE(imIn, tarIn, wWin, sampleCoords)
%
% Output:
%   StatsOut.S:         similarity (signed)
%   StatsOut.Smag:      magnitude of similarity (unsigned)
%
% v1.0, 1/5/2016, Steve Sebastian <sebastian@utexas.edu>


%% Variable set up/
iWin = wWin > 0;
cosWin = nm.lib.cosWindowFlattop2(size(imIn), 90, 10, 0, 0);
paddedImage = ones([128, 128]);

targetSizePix = size(tarIn);

tarIn = tarIn.*cosWin;
tarInPadded = paddedImage.*0;
tarInPadded(1:targetSizePix(1),1:targetSizePix(2)) = tarIn;

tarInPaddedF = abs(fft2(tarInPadded));
tarInNorm = sqrt(sum(tarInPaddedF(:).^2));

nSamples = size(sampleCoords, 1);

StatsOut.S    = zeros(nSamples, 1);
StatsOut.Smag = zeros(nSamples, 1);

%% Compute Similarity at each location in sampleCoords.
for sItr = 1:nSamples
    imgSmall    = cropImage(imIn, sampleCoords(sItr,:), targetSizePix, [], 1);
    imgSmall    = imgSmall.*iWin;
    meanImg     = mean(imgSmall(iWin));
    imgSmall    = (imgSmall - meanImg).*cosWin;
    
    imgSmallPadded = paddedImage;
    imgSmallPadded(1:targetSizePix(1),1:targetSizePix(2)) = imgSmall;
    
    imgSmallPaddedF = abs(fft2(imgSmallPadded));
    imgNorm = sqrt(sum(imgSmallPaddedF(:).^2));
    
    templateMatch = sum(imgSmallPaddedF(:).*tarInPaddedF(:));
   
    StatsOut.S(sItr)    = templateMatch./(imgNorm.*tarInNorm);  
    StatsOut.Smag(sItr) = abs(StatsOut.S(sItr));
end