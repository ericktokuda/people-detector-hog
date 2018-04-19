function hog_process_list(list, outdir, thresh)
  % PROCESS_LIST Process images in a give list and output to outdir.
  if (nargin < 2)
    disp('Requires inputdir, outputdir. [threshold]')
    return
  elseif (nargin == 2)
    thresh = 0;
  end

  if ~exist(outdir, 'dir')
    mkdir (outdir);
  end

  fh = fopen(list);

  %files = dir(fullfile(indir, '*.jpg'));
  detector = vision.PeopleDetector('UprightPeople_96x48', 'MinSize', [96 48]);

  totaltime = 0
  while true
    file = fgetl(fh);  % read line excluding newline character
    if ~ischar(file); break; end  %end of file
    [~, imgname, ~] = fileparts(file);
    totaltime = totaltime + process_image(detector, imgname, file, outdir, thresh);
  end
  disp(totaltime)

function elapsedtime = process_image(detector, imgname, fullimage, outdir, thresh)
  %PROCESS_IMAGE Process one image 

  disp(imgname)
  I = imread(fullimage);
  tic;
  [bboxes, scores] = step(detector, I);
  elapsedtime = toc;
  bboxesfiltered = bboxes(find(scores > thresh), :);
  scoresfiltered = scores(find(scores > thresh));

  [l, c] = size(bboxesfiltered);

  vocbbox = zeros(l, 5);

  for lidx = 1:l
    for cidx = 1:c
      if cidx < 3
        vocbbox(lidx, cidx) = bboxesfiltered(lidx, cidx) - 1;
      else
        lenght = bboxesfiltered(lidx, cidx);
        vocbbox(lidx, cidx) = bboxesfiltered(lidx, cidx) + lenght;
      end
    end
    vocbbox(lidx, 5) = scoresfiltered(lidx);
  end

  %outfilename = fullfile(outdir, imgname);
  %if size(bboxesfiltered) > 0
    %I = insertObjectAnnotation(I, 'rectangle', bboxesfiltered, ...
      %scoresfiltered, 'LineWidth', 10);
  %end
  %imwrite(I, outfilename);

  outcsv = fullfile(outdir, strcat(imgname, '.csv'));
  csvwrite(outcsv, vocbbox)
