


close all; clear; clc

 
% Load the image sequence
imageDir = 'C:\Users\jyl772\Desktop\Mask Files\Bubble\Bubble Mask Temporal Initial';  % Replace with the path to your image sequence folder
imageFiles = dir(fullfile(imageDir, '*.tif')); % Adjust the file extension as needed

% Load the image sequence
% imageDir = 'your_image_sequence_folder';  % Replace with the path to your image sequence folder
% imageFiles = dir(fullfile(imageDir, '*.tif')); % Adjust the file extension as needed

% Initialize a cell array to store the frames
frames = cell(1, numel(imageFiles));


for i = 1:numel(imageFiles)
    % Load each frame and convert it to grayscale
    currentFrame = imread(fullfile(imageDir, imageFiles(i).name));
    frames{i} = double(rgb2gray(currentFrame));  % Convert to grayscale
end



frames_orig = frames;


% Determine the dimensions of the images (assuming all images have the same size)
imageSize = size(frames{1});

% Initialize a 3D matrix to store the grayscale images for each frame
numFrames = numel(frames);
imageSequence = zeros([imageSize, numFrames]);

% Loop through the cell array and stack the grayscale images into the 3D matrix
for frameIndex = 1:numFrames
    imageSequence(:, :, frameIndex) = frames{frameIndex};
end


% Define a threshold based on variance (you can adjust this threshold)
varianceThreshold = 50000;

% Initialize an array to store the variance of each frame
variances = zeros(1, numel(frames));

% Calculate the variance of pixel values for each frame
for i = 1:numel(frames)
    variances(i) = var(frames{i}(:)); % Calculate variance of pixel values
end

% Identify "bad" frames based on the variance threshold
badFrameIndices1 = find(variances > varianceThreshold);

badFrameIndices2 = find(variances==0);

badFrameIndices = unique( [ badFrameIndices1,badFrameIndices2,badFrameIndices2-1,badFrameIndices2+1 ] );



% Remove bad frames
imageSequence(:,:,badFrameIndices) = nan;

% Set the number of neighboring frames for the temporal filter
numNeighbors = 2;  % Adjust as needed

% Set a standard deviation for the Gaussian filter to increase smoothing
sigma = 2;  % Adjust as needed

% Create a copy of the image sequence to work with
filledImageSequence = imageSequence;

% Loop through frames
for frameIndex = 1:size(imageSequence, 3)
    frame = imageSequence(:, :, frameIndex);
    
    % Check for NaN values in the frame
    nanMask = isnan(frame);
    
   if any(nanMask(:))

        % Determine the frame indices of neighboring frames
        neighborIndices = max(1, frameIndex - numNeighbors):min(size(imageSequence, 3), frameIndex + numNeighbors);
        
        % Extract neighboring frames
        neighborFrames = imageSequence(:, :, neighborIndices);


        for tempi = 1:size(neighborFrames,3)

            tempframe = neighborFrames(:,:,tempi);
            tempframe = imgaussfilt(tempframe, sigma);
            neighborFrames(:,:,tempi) = tempframe;

        end
        
        % Compute the temporal average excluding NaN values
        temporalAverage = nanmean(neighborFrames, 3);
        
        % Replace NaN values in the frame with the temporal average
        filledImageSequence(:, :, frameIndex) =  reshape(temporalAverage(nanMask),  size(filledImageSequence,1) , size(filledImageSequence,2), 1);

    end

end








%% Temporal smoothing

% Define the size of the 3D Gaussian kernel
kernelSize = [5, 5, 5];  % Adjust the size as needed


% Set the standard deviation for the temporal Gaussian filter
sigma = 2;  % Adjust as needed

% Create the 3D Gaussian kernel
gaussianKernel = fspecial3('gaussian', kernelSize, sigma);



% Create a copy of the image sequence to work with
smoothedImageSequence = filledImageSequence;

% Apply the 3D Gaussian filter to each frame in the sequence
for frameIndex = 1:size(imageSequence, 3)

    frame = filledImageSequence(:, :, frameIndex);
    
    % Apply the 3D Gaussian filter to the frame
    smoothedFrame = imfilter(frame, gaussianKernel, 'conv', 'replicate');
    
    % Replace the original frame with the smoothed frame
    smoothedImageSequence(:, :, frameIndex) = smoothedFrame;
end


 
filteredFrames =  cell(1, numel(imageFiles));

% Loop through the cell array and stack the images into the 3D matrix
for frameIndex = 1:numFrames
     filteredFrames{frameIndex} = smoothedImageSequence(:, :, frameIndex)>0.4999;
end

% Specify the output folder
outputDir = 'C:\Users\jyl772\Desktop\Mask Files\Bubble\Bubble Mask Temporal';  % Replace with the path to your desired output folder
mkdir(outputDir);  % Create the output folder if it doesn't exist

% Loop through the cell array and stack the images into the 3D matrix
for frameIndex = 1:numFrames
    % Save the filtered frame as a binary image in the output folder
    imwrite(filteredFrames{frameIndex}, fullfile(outputDir, sprintf('filtered_frame_%03d.tif', frameIndex)));
end




%%
 figure;

% Display the original and filtered frames
for i = 1 : numel(frames)  %  100 : 120  %
   
    subplot(2, 2, 1);
    imshow(frames_orig{i});
    title(['Original Frame ', num2str(i)]);
    
    subplot(2, 2, 2);
    imshow(filteredFrames{i});
    title(['Filtered Frame ', num2str(i)]);

     subplot(2, 2, 3);
    imshow(frames_orig{i} - filteredFrames{i});
    title(['Diff Filtered Frame ', num2str(i)]);

    pause( .1 );

end

