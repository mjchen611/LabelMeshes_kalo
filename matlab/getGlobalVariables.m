%% general parameters
PRINCETON_DATA_PATH = 'princeton\data';
HUMAN_SEG_DATA_PATH = 'princeton\data\seg\Benchmark';
HUMAN_EVAL_DATA_PATH = 'princeton\evaluation\eval-raw\Benchmark';
OFF_DATA_PATH = 'princeton\data\off';

USE_JOINTBOOST = 1;

EXEC_PATH = 'LearningMeshSegmentation.exe';
SYSTEM_SLASH = '/';
MESHES_LABELS_FILE = 'meshes.txt';    % these should be all the same with the C++ program output filenames
PWPARMS_FILE = 'pwparms.txt';
EDGESPWPARMS_FILE = 'pwparmsedges.txt';
NLOGW_FILE = 'nlogw.txt';
EDGESNLOGW_FILE = 'nlogwedges.txt';
CVNLOGW_FILE = 'cvnlogw.txt';
CVEDGESNLOGW_FILE = 'cvnlogwedges.txt';
% WHITENING_FILE = 'pwparmsWhiten.txt';
% KMEANS_FILE = 'pwdictionary.txt';

EPSILON = 1e-30;

APPEND_TIMEDATE_TO_MAT_FILES = false;

warning('off', 'MATLAB:dispatcher:nameConflict');
addpath('GCMex');


%% subject to testing
TRAINING_ITERATIONS = 30;       % CRF optimization
MIN_EXPARM_VALUE = .01;
MIN_ALLOWED_EXPARM_VALUE = 1e-6;
MAX_EXPARM_VALUE = 3;
MAX_ALLOWED_EXPARM_VALUE = 50;
INITIAL_SEARCH_SPACE_VALUES = 6;
NUMERICAL_DERIV_DIFF_MAX = 1;

%% feature positions indices (nlogw)
ADABOOST_UNARY_POS = 1;
FEATURE_ORDER = [ADABOOST_UNARY_POS];
UNARY_POS = length(FEATURE_ORDER) + 1;
ADABOOST_EDGE_POS  = UNARY_POS + 1;


%% CRF parameters indices (exparms)
ADABOOST_EDGE_SPV_MULT  = 1;
EDGELENGTH_SPV_MULT     = 2;
CONVEXITY_SPV_MULT      = 3;
% ADABOOST_UNARY_MULT     = 4;
TOTAL_EXPARMS           = CONVEXITY_SPV_MULT;

CRF_MULT = 1;
CRF_SPINV = 2;

%% other

CATEGORIES = {'Human', 'Cup', 'Glasses', 'Airplane', 'Ant', 'Chair', 'Octopus', 'Table', 'Teddy', 'Hand', 'Plier', 'Fish', 'Bird', 'Spring', 'Armadillo', 'Bust', 'Mech', 'Bearing', 'Vase', 'FourLeg' };
%CATEGORIES = {'', 'Cup', 'Glasses', 'Airplane', 'Ant', 'Chair', 'Octopus', 'Table', '', 'Hand', 'Plier', 'Fish', 'Bird', 'Spring', '', '', 'Mech', 'Bearing', 'Vase', 'FourLeg' };

% CURVATURE_FEATURES = 1;
% PCA_FEATURES = 2;
% INTEGRAL_INVARIANT_FEATURES = 3;
% SDF_FEATURES = 4;
% SHAPE_CONTEXT_FEATURES = 5;
% GEODESICS_FEATURES = 6;
% SH_FEATURES = 7;
% LOCATION_FEATURES = 8;
% TOTAL_FEATURE_SETS = 8;
% EDGE_FEATURES = TOTAL_FEATURE_SETS + 1;

%featureORDER = [CURVATURE_FEATURES; PCA_FEATURES; SHAPE_CONTEXT_FEATURES; GEODESICS_FEATURES; SDF_FEATURES];
