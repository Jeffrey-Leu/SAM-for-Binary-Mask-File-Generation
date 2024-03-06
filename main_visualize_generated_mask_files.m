


%% Generate a video

outputVideoFile = 'video';
% Create a VideoWriter object
outputVideo = VideoWriter(outputVideoFile, 'MPEG-4'); % Adjust the format as needed
outputVideo.FrameRate = 30; % Adjust the frame rate as needed

% Open the VideoWriter object
open(outputVideo);


% Set the path to the directory containing the image sequence
% sequenceDir = './bubble_mask/';
% sequenceDir_sm = './bubble_mask_diffusion_smoothed/';
% sequenceDir_orig = './bubble_orig/';

% sequenceDir = './interface_mask/';
% sequenceDir_sm = './interface_mask_diffusion_smoothed/';
% sequenceDir_orig = './interface_orig/';

sequenceDir = 'C:\Users\jyl772\Desktop\Mask Files\AL5\AL5 Binary\';
sequenceDir_sm = 'C:\Users\jyl772\Desktop\Mask Files\AL5\AL5 Diffusion\';
sequenceDir_orig = 'C:\Users\jyl772\Desktop\Mask Files\AL5\AL5\';
 

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
for imgInd =   1 : numel(imageFiles)


    % =========================================
    % Read the image
    imagePath = fullfile(sequenceDir, imageFiles(imgInd).name);
    frame_meta =  double(imread(imagePath));
    if max(frame_meta(:))==1, frame_meta = frame_meta*255; end
    % Define the size of the median filter window (you can adjust this)
    % filterSize = 4; % Experiment with different values

    % Apply the median filter
    % frame_meta = medfilt2(frame_meta, [filterSize, filterSize]);


    Img{imgInd} = frame_meta;

    % Display the image
    subplot(2,2,1); imshow(255-frame_meta);
    title(['Meta generated mask file #',num2str(imgInd)])


    % =========================================
    % Read the image
    imagePath = fullfile(sequenceDir_sm, imageFiles_sm(imgInd).name);
    frame_sm = imread(imagePath);
    Img_sm{imgInd} = frame_sm;
    % frame_sm = medfilt2(frame_sm, [filterSize, filterSize]);
    % if max(frame_sm(:))==1, frame_sm = frame_sm*255; end
    subplot(2,2,2); imshow( frame_sm );
    title(['Improved generated mask file #',num2str(imgInd)])

    % =========================================
    % Read the image
    imagePath = fullfile(sequenceDir_orig, imageFiles_orig(imgInd).name);
    frame_orig = imread(imagePath);
    %      Img_orig{imgInd} = frame_orig;
    %  subplot(2,2,3); imshow(frame_orig);

    

    subplot(2,2,3);

    backgroundImage = double(frame_orig);
    binaryOverlayImage = double(1-uint8(frame_meta));

    % Convert the binary overlay image to the same bit depth as the background image
    maxValue = 2^8 - 1; % Maximum value for a 16-bit image
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
    combinedImage = uint8(combinedImage);

    % Display the combined image using imshow

    imshow(combinedImage, []);


    title('Overlays w/ original image')

    imagePath = fullfile(sequenceDir_orig, imageFiles_orig(imgInd).name);
    frame_orig = imread(imagePath);
    Img_orig{imgInd} = frame_orig;

    %========================================
    subplot(2,2,4);

    backgroundImage = double(frame_orig);
    binaryOverlayImage = double(uint8(frame_sm));

    % Convert the binary overlay image to the same bit depth as the background image
    maxValue = 2^8 - 1; % Maximum value for a 16-bit image
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
    combinedImage = uint8(combinedImage);

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