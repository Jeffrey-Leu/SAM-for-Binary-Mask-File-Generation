

close all; clear; clc

%%


% Set the path to the directory containing the image sequence
sequenceDir = 'C:\Users\jyl772\Desktop\Mask Files\Interface\Interface Binary Inverted';

% Check if the directory exists
if ~isfolder(sequenceDir)
    error(['Directory ', sequenceDir, ' does not exist.']);
end

% Get a list of image files in the directory (assuming the files are in order)
imageFiles = dir(fullfile(sequenceDir, '*.tif')); % Change the extension to match your image format

Img = cell(length(imageFiles),1);


% Specify the directory where you want to save the image files
outputDirectory = 'C:\Users\jyl772\Desktop\Mask Files\Interface\Interface Diffusion';


figure(1);

%%

% Loop through the image files and display them
for imgInd = 1 : numel(imageFiles)
    % Read the image
    imagePath = fullfile(sequenceDir, imageFiles(imgInd).name);
    originalImage = imread(imagePath);

    % Convert the image to double precision for calculations
    originalImage = im2double(originalImage);

    % Set parameters for the Perona-Malik equation
    numIterations = 80; % Number of iterations
    dt = .1; % Time step (adjust as needed)
    lambda = 0.25; % Diffusion coefficient (adjust as needed)
    viscousness = 0.0; % Adjust the viscousness parameter
    surfaceTension = 0.5; % Surface tension coefficient (adjust as needed)

    % Set parameters for the Gaussian filter
    gaussianSigma = 2.0; % Adjust as needed
    gaussianSize = 5; % Adjust as needed


    % Initialize the smoothed image as the original image
    smoothedImage = originalImage;

    % Create a Laplacian kernel for divergence calculation
    laplacianKernel = [0 1 0; 1 -4 1; 0 1 0];

    % Apply the Perona-Malik equation for image smoothing
    for iteration = 1 : numIterations

        % Calculate the gradient of the smoothed image
        [Gx, Gy] = gradient(smoothedImage);

        % Compute the diffusivity function using the gradient magnitude
        diffusivity = exp(-(Gx.^2 + Gy.^2) / (2 * lambda^2));

        % Calculate the Laplacian of the diffusivity function
        laplacianDiffusivity = imfilter(diffusivity, laplacianKernel, 'symmetric');

        % Calculate the viscous term (smoothing term)
        viscousTerm = viscousness * del2(smoothedImage);

        % Calculate the curvature of the smoothed image
        [Gxx, Gyy] = gradient(Gx);
        [Gxy, Gyx] = gradient(Gy);
        curvature = Gxx + Gyy;

        % Add the surface tension term
        surfaceTensionTerm = surfaceTension * curvature;

        % Update the smoothed image using the Perona-Malik equation
        smoothedImage = smoothedImage + dt * (laplacianDiffusivity .* del2(smoothedImage)) - dt * surfaceTensionTerm - dt * viscousTerm;


        % Apply a Gaussian filter to the smoothed image for additional smoothing
        smoothedImage = imgaussfilt(smoothedImage, gaussianSigma, 'FilterSize', gaussianSize);
        smoothedImageMask = smoothedImage > 0.5;

        % Display the original and smoothed images
        subplot(2, 2, 1);
        surf(originalImage,'edgecolor','none'); view(2); caxis([-2,2]); axis equal; axis tight;
        title('Original Image');

        subplot(2, 2, 2);
        surf(smoothedImage,'edgecolor','none'); view(2); caxis([-2,2]); axis equal; axis tight;
        title(['Smoothed Image at Iter ',num2str(iteration)]);

        subplot(2, 2, 3);
        imshow(originalImage); view(2); caxis([0 1]); axis equal; axis tight;
        title(['Original Image mask file']);

        subplot(2, 2, 4);
        imshow( smoothedImageMask ); view(2); caxis([0 1]); axis equal; axis tight;
        title(['Smoothed Image at Iter ',num2str(iteration)]);


        pause(0.1);


    end


    % Specify the file name and format (e.g., 'my_generated_image.tif')
    baseFilename = 'image_mask_smoothed_';

    % Specify the file format (e.g., 'tif')
    fileFormat = 'tif';
    outputFileName = sprintf('%s%04d.%s', baseFilename, imgInd, fileFormat);

    % Save the image to the specified output directory with the generated filename
    fullFilePath = fullfile(outputDirectory, outputFileName);
    imwrite(smoothedImageMask, fullFilePath);


end



 

%% Generate a video

outputVideoFile = 'video';
% Create a VideoWriter object
outputVideo = VideoWriter(outputVideoFile, 'MPEG-4'); % Adjust the format as needed
outputVideo.FrameRate = 30; % Adjust the frame rate as needed

% Open the VideoWriter object
open(outputVideo);


% Set the path to the directory containing the image sequence
sequenceDir = './bubble_mask/';
sequenceDir_sm = './bubble_mask_smoothed/';
sequenceDir_orig = './bubble_orig/';

% Check if the directory exists
if ~isfolder(sequenceDir)
    error(['Directory ', sequenceDir, ' does not exist.']);
end

% Get a list of image files in the directory (assuming the files are in order)
imageFiles = dir(fullfile(sequenceDir, '*.tif')); % Change the extension to match your image format
imageFiles_sm = dir(fullfile(sequenceDir_sm, '*.tif')); % Change the extension to match your image format
imageFiles_orig = dir(fullfile(sequenceDir_orig, '*.tif')); % Change the extension to match your image format


Img = cell(length(imageFiles),1);
Img_sm = cell(length(imageFiles_sm),1);
Img_orig = cell(length(imageFiles_orig),1);


% Loop through the image files and display them
for imgInd = 1:numel(imageFiles)


    % =========================================
    % Read the image
    imagePath = fullfile(sequenceDir, imageFiles(imgInd).name);
    frame_meta = double(imread(imagePath));

    % Define the size of the median filter window (you can adjust this)
    % filterSize = 4; % Experiment with different values

    % Apply the median filter
    % frame = medfilt2(frame, [filterSize, filterSize]);


    Img{imgInd} = frame_meta;

    % Display the image
    subplot(2,2,1); imshow(1-frame_meta);
    title('Meta generated mask file')


    % =========================================
    % Read the image
    imagePath = fullfile(sequenceDir_sm, imageFiles_sm(imgInd).name);
    frame_sm = imread(imagePath);
    Img_sm{imgInd} = frame_sm;
    subplot(2,2,2); imshow(1- frame_sm );
    title('Improved generated mask file')


    % =========================================
    % Read the image
    imagePath = fullfile(sequenceDir_orig, imageFiles_orig(imgInd).name);
    frame_orig = imread(imagePath);
    %      Img_orig{imgInd} = frame_orig;
    %  subplot(2,2,3); imshow(frame_orig);

    subplot(2,2,3);

    backgroundImage = double(frame_orig);
    binaryOverlayImage = double(1-frame_meta);

    % Convert the binary overlay image to the same bit depth as the background image
    maxValue = 2^16 - 1; % Maximum value for a 16-bit image
    binaryOverlayImage = binaryOverlayImage * maxValue; % Convert to 16-bit

    % Resize overlay image to match the size of the background image
    binaryOverlayImage = imresize(binaryOverlayImage, size(backgroundImage));

    % Define the desired transparency level for the binary overlay
    opacity = 0.5; % Adjust the opacity (0.5 for 50% opacity)

    % Create the combined image with transparency
    combinedImage = double(backgroundImage);

    % Overlay the binary image on top of the background image with transparency
    combinedImage = (1 - opacity) * combinedImage + opacity * double(binaryOverlayImage);

    % Convert the combined image back to 16-bit
    combinedImage = uint16(combinedImage);

    % Display the combined image using imshow

    imshow(combinedImage, []);


    title('Overlays w/ original image')

    imagePath = fullfile(sequenceDir_orig, imageFiles_orig(imgInd).name);
    frame_orig = imread(imagePath);
    Img_orig{imgInd} = frame_orig;

    %========================================
    subplot(2,2,4);

    backgroundImage = double(frame_orig);
    binaryOverlayImage = double(1-frame_sm);

    % Convert the binary overlay image to the same bit depth as the background image
    maxValue = 2^16 - 1; % Maximum value for a 16-bit image
    binaryOverlayImage = binaryOverlayImage * maxValue; % Convert to 16-bit

    % Resize overlay image to match the size of the background image
    binaryOverlayImage = imresize(binaryOverlayImage, size(backgroundImage));

    % Define the desired transparency level for the binary overlay
    opacity = 0.5; % Adjust the opacity (0.5 for 50% opacity)

    % Create the combined image with transparency
    combinedImage = double(backgroundImage);

    % Overlay the binary image on top of the background image with transparency
    combinedImage = (1 - opacity) * combinedImage + opacity * double(binaryOverlayImage);

    % Convert the combined image back to 16-bit
    combinedImage = uint16(combinedImage);

    % Display the combined image using imshow

    imshow(combinedImage, []);


    title('Overlays w/ original image')



    % Pause to display the frame for a specific duration (e.g., 0.1 seconds)
    pause(0.1);




    frame_meta = getframe(gcf);
    writeVideo(outputVideo, frame_meta);



end

% Close the VideoWriter object to save the video
close(outputVideo);

% Display a message when the video is saved
fprintf('Video saved as %s\n', outputVideoFile);




