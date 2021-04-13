function [ssimval, ssimmap] = ssim(varargin)
%SSIM Structural Similarity Index for measuring image quality
%   SSIMVAL = SSIM(A, REF) calculates the Structural Similarity Index
%   (SSIM) value for image A, with the image REF as the reference. A and
%   REF can be 2D grayscale or 3D volume images, and must be of the same
%   size and class. The similarity metric, SSIMVAL, is a double valued
%   scalar. A value of 1 corresponds to the highest quality (when A and
%   REF are equivalent).
%
%   [SSIMVAL, SSIMMAP] = SSIM(A, REF) also returns the local SSIM value for
%   each pixel in SSIMMAP. SSIMMAP has the same size as A.
%
%   [SSIMVAL, SSIMMAP] = SSIM(A, REF, NAME1, VAL1,...) calculates the SSIM
%   value using name-value pairs to control aspects of the computation.
%   Parameter names can be abbreviated.
%
%   Parameters include:
%
%   'Radius'                 - Specifies the standard deviation of
%                              isotropic Gaussian function used for
%                              weighting the neighborhood pixels around a
%                              pixel for estimating local statistics. This
%                              weighting is used to avoid blocking
%                              artifacts in estimating local statistics.
%                              The default value is 1.5.
%
%   'DynamicRange'           - Positive scalar, L, that specifies the
%                              dynamic range of the input image. By
%                              default, L is chosen based on the class of
%                              the input image A, as L =
%                              diff(getrangefromclass(A)). Note that when
%                              class of A is single or double, L = 1 by
%                              default.
%
%   'RegularizationConstants'- Three-element vector, [C1 C2 C3], of
%                              non-negative real numbers that specifies the
%                              regularization constants for the luminance,
%                              contrast, and structural terms (see [1]),
%                              respectively. The regularization constants
%                              are used to avoid instability for image
%                              regions where the local mean or standard
%                              deviation is close to zero. Therefore, small
%                              non-zero values should be used for these
%                              constants. By default, C1 = (0.01*L).^2, C2
%                              = (0.03*L).^2, and C3 = C2/2, where L is the
%                              specified 'DynamicRange' value. If a value
%                              of 'DynamicRange' is not specified, the
%                              default value is used (see name-value pair
%                              'DynamicRange').
%
%   'Exponents'               - Three-element vector [alpha beta gamma],
%                               of non-negative real numbers that specifies
%                               the exponents for the luminance, contrast,
%                               and structural terms (see [1]),
%                               respectively. By default, all the three
%                               exponents are 1, i.e. the vector is [1 1
%                               1].
%
%   Class Support
%   -------------
%   Input arrays A and REF must be one of the following classes: uint8,
%   int16, uint16, single, or double. Both A and REF must be of the same
%   class. They must be nonsparse. SSIMVAL is a scalar and SSIMMAP is an
%   array of the same size as A. Both SSIMVAL and SSIMMAP are of class
%   double, unless A and REF are of class single in which case SSIMVAL and
%   SSIMMAP are of class single.
%
%   Notes
%   -----
%   1. A and REF can be arrays of up to three dimensions. All 3D arrays
%      are considered 3D volumetric images. RGB images will also be
%      processed as 3D volumetric images.
%
%   2. Input image A and reference image REF are converted to
%      floating-point type for internal computation.
%
%   3. For signed-integer images (int16), an offset is applied to bring the
%      gray values in the non-negative range before computing the SSIM
%      index.
%
%   4. SSIMVAL is 1 when A and REF are equivalent indicating highest
%      quality. Smaller values indicate deviations. For some combinations
%      of inputs and parameters, SSIMVAL can be negative.
%
%   5. When non-integer valued 'Exponents' are used, intermediate
%      luminance, contrast and structural terms are clamped to [0, inf]
%      range to prevent complex valued outputs.
%
%   References:
%   -----------
%   [1] Z. Wang, A. C. Bovik, H. R. Sheikh, and E. P. Simoncelli, "Image
%       Quality Assessment: From Error Visibility to Structural
%       Similarity," IEEE Transactions on Image Processing, Volume 13,
%       Issue 4, pp. 600- 612, 2004.
%
%   Example
%   ---------
%   % This example shows how to compute SSIM value for a blurred image 
%   % given the original reference image.
%
%   ref = imread('pout.tif');
%   A = imgaussfilt(ref, 1.5, 'FilterSize', 11, 'Padding', 'replicate');
%
%   subplot(1,2,1); imshow(ref); title('Reference Image');
%   subplot(1,2,2); imshow(A);   title('Blurred Image');
%
%   [ssimval, ssimmap] = ssim(A,ref);
%
%   fprintf('The SSIM value is %0.4f.\n',ssimval);
%
%   figure, imshow(ssimmap,[]);
%   title(sprintf('SSIM Index Map - Mean SSIM Value is %0.4f',ssimval));
%   
%   See also IMMSE, MEAN, MEDIAN, PSNR, SUM, VAR.

%   Copyright 2013-2020 The MathWorks, Inc.

narginchk(2,10);

matlab.images.internal.errorIfgpuArray(varargin{:});
args = matlab.images.internal.stringToChar(varargin);
[A, ref, C, exponents, radius] = parse_inputs(args{:});

if isempty(A)
    ssimval = zeros(0, 'like', A);
    ssimmap = A;
    return;
end

if isa(A,'int16') % int16 is the only allowed signed-integer type for A and ref.
    % Add offset for signed-integer types to bring values in the
    % non-negative range.
    A = double(A) - double(intmin('int16'));
    ref = double(ref) - double(intmin('int16'));
elseif isinteger(A)
    A = double(A);
    ref = double(ref);
end

filtRadius = ceil(radius*3); % 3 Standard deviations include >99% of the area.
filtSize = 2*filtRadius + 1;

if ismatrix(A)
    gaussFilterFcn = @(X)imgaussfilt(X, radius, 'FilterSize', filtSize, 'Padding','replicate');
else
    gaussFilterFcn = @(X)imgaussfilt3(X, radius, 'FilterSize', filtSize, 'Padding','replicate');
end
% Weighted-mean and weighted-variance computations
mux2 = gaussFilterFcn(A);
muy2 = gaussFilterFcn(ref);
muxy = mux2.*muy2;
mux2 = mux2.^2;
muy2 = muy2.^2;

% Clamp to zero. Floating point math sometimes makes this negative
sigmax2 = max(gaussFilterFcn(A.^2) - mux2,0);
sigmay2 = max(gaussFilterFcn(ref.^2) - muy2,0);

sigmaxy = gaussFilterFcn(A.*ref) - muxy;

% Compute SSIM index
if (C(3) == C(2)/2) && isequal(exponents(:),ones(3,1))
    % Special case: Equation 13 from [1]
    num = (2*muxy + C(1)).*(2*sigmaxy + C(2));
    den = (mux2 + muy2 + C(1)).*(sigmax2 + sigmay2 + C(2));
    if (C(1) > 0) && (C(2) > 0)
        ssimmap = num./den;
    else
        % Need to guard against divide-by-zero if either C(1) or C(2) is 0.
        isDenNonZero = (den ~= 0);
        ssimmap = ones(size(A));
        ssimmap(isDenNonZero) = num(isDenNonZero)./den(isDenNonZero);
    end

else
    % General case: Equation 12 from [1]
    % Luminance term
    if (exponents(1) > 0)
        num = 2*muxy + C(1);
        den = mux2 + muy2 + C(1);
        ssimmap = guardedDivideAndExponent(num,den,C(1),exponents(1));
    else
        ssimmap = ones(size(A), 'like', A);
    end

    % Contrast term
    sigmaxsigmay = [];
    if (exponents(2) > 0)
        sigmaxsigmay = sqrt(sigmax2.*sigmay2);
        num = 2*sigmaxsigmay + C(2);
        den = sigmax2 + sigmay2 + C(2);
        ssimmap = ssimmap.*guardedDivideAndExponent(num,den,C(2),exponents(2));
    end

    % Structure term
    if (exponents(3) > 0)
        num = sigmaxy + C(3);
        if isempty(sigmaxsigmay)
            sigmaxsigmay = sqrt(sigmax2.*sigmay2);
        end
        den = sigmaxsigmay + C(3);
        ssimmap = ssimmap.*guardedDivideAndExponent(num,den,C(3),exponents(3));
    end

end

ssimval = mean(ssimmap(:));

end

% -------------------------------------------------------------------------
function component = guardedDivideAndExponent(num, den, C, exponent)

if C > 0
    component = num./den;
else
    component = ones(size(num),'like',num);
    isDenNonZero = (den ~= 0);
    component(isDenNonZero) = num(isDenNonZero)./den(isDenNonZero);
end

if exponent~=floor(exponent) 
    % This deviates from the authors implementation. Raising a negative
    % value to non integer exponents result in complex values. Clamp this
    % to 0 to workaround this edge case.
    component = max(component,0);
end

if(exponent ~= 1)
    component = component.^exponent;
end

end

function [A, ref, C, exponents, radius] = parse_inputs(varargin)

validImageTypes = {'uint8','uint16','int16','single','double'};

A = varargin{1};
validateattributes(A,validImageTypes,{'nonsparse','real'},mfilename,'A',1);

ref = varargin{2};
validateattributes(ref,validImageTypes,{'nonsparse','real'},mfilename,'REF',2);

if ~isa(A,class(ref))
    error(message('images:validate:differentClassMatrices','A','REF'));
end

if ~isequal(size(A),size(ref))
    error(message('images:validate:unequalSizeMatrices','A','REF'));
end

if (ndims(A) > 3)
    error(message('images:validate:tooManyDimensions','A and REF',3));
end

% Default values for parameters
dynmRange = diff(getrangefromclass(A));
C = [];
exponents = [1 1 1];
radius = 1.5;

args_names = {'dynamicrange', 'regularizationconstants','exponents',...
              'radius'};

for i = 3:2:nargin
    arg = varargin{i};
    if ischar(arg)
        idx = find(strncmpi(arg, args_names, numel(arg)));
        if isempty(idx)
            error(message('images:validate:unknownInputString', arg))

        elseif numel(idx) > 1
            error(message('images:validate:ambiguousInputString', arg))

        elseif numel(idx) == 1
            if (i+1 > nargin)
                error(message('images:validate:missingParameterValue'));
            end
            if idx == 1
                dynmRange = varargin{i+1};
                validateattributes(dynmRange,{'numeric'},{'positive', ...
                    'finite', 'real', 'nonempty','scalar'}, mfilename, ...
                    'DynamicRange',i);
                dynmRange = double(dynmRange);

            elseif idx == 2
                C = varargin{i+1};
                validateattributes(C,{'numeric'},{'nonnegative','finite', ...
                    'real','nonempty','vector', 'numel', 3}, mfilename, ...
                    'RegularizationConstants',i);
                C = double(C);

            elseif idx == 3
                exponents = varargin{i+1};
                validateattributes(exponents,{'numeric'},{'nonnegative', ...
                    'finite', 'real', 'nonempty','vector', 'numel', 3}, ...
                    mfilename,'Exponents',i);
                exponents = double(exponents);

            elseif idx == 4
                radius = varargin{i+1};
                validateattributes(radius,{'numeric'},{'positive','finite', ...
                    'real', 'nonempty','scalar'}, mfilename,'Radius',i);
                radius = double(radius);
            end
        end
    else
        error(message('images:validate:mustBeString'));
    end
end

% If 'RegularizationConstants' is not specified, choose default C.
if isempty(C)
    C = [(0.01*dynmRange).^2 (0.03*dynmRange).^2 ((0.03*dynmRange).^2)/2];
end

end
