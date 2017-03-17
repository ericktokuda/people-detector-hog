function process_dir(indir, outdir, thresh)
% PROCESS_DIR Process all the jpg images in indir and output to outdir.
    if (nargin < 2)
        disp('Requires inputdir, outputdir. [threshold]')
        return
    elseif (nargin == 2)
        thresh = 0.2;
    end

    if ~exist(outdir, 'dir')
        mkdir (outdir);
    end
    
    files = dir(fullfile(indir, '*.jpg'));
    detector = vision.PeopleDetector('UprightPeople_96x48', 'MinSize', [96 48]);

    for file = files'
        disp(file.name)
        process_image(detector, file.name, indir, outdir, thresh);
    end

function process_image(detector, imgname, indir, outdir, thresh)
%PROCESS_IMAGE Process one image 
    if (nargin == 4)
        thresh = 0.02;
    end
    
	I = imread(fullfile(indir, imgname));
	[bboxes, scores] = step(detector, I);
	bboxesfiltered = bboxes(find(scores > thresh), :);
	scoresfiltered = scores(find(scores > thresh));

	if size(bboxesfiltered) > 0
		I = insertObjectAnnotation(I, 'rectangle', bboxesfiltered, ...
		scoresfiltered, 'LineWidth', 10);
	end

