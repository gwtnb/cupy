# distutils: language = c++

"""Thin wrapper of cuDNN."""
# NOTE: This wrapper does not cover all APIs of cuDNN v4.
cimport cython  # NOQA
from libcpp cimport vector

from cupy.cuda cimport driver
from cupy.cuda cimport stream as stream_module

###############################################################################
# Extern
###############################################################################

cdef extern from 'cupy_cudnn.h' nogil:
    # Types
    ctypedef int ActivationMode 'cudnnActivationMode_t'
    ctypedef int AddMode 'cudnnAddMode_t'
    ctypedef int AttnQueryMap 'cudnnAttnQueryMap_t'
    ctypedef int MultiHeadAttnWeightKind 'cudnnMultiHeadAttnWeightKind_t'
    ctypedef int BatchNormMode 'cudnnBatchNormMode_t'
    ctypedef int BatchNormOps 'cudnnBatchNormOps_t'
    ctypedef int ConvolutionBwdDataAlgo 'cudnnConvolutionBwdDataAlgo_t'
    ctypedef int ConvolutionBwdDataPreference \
        'cudnnConvolutionBwdDataPreference_t'
    ctypedef struct ConvolutionBwdDataAlgoPerf \
        'cudnnConvolutionBwdDataAlgoPerf_t':  # NOQA: E125
        int algo
        int status
        float time
        size_t memory
    ctypedef struct ConvolutionBwdDataAlgoPerf_v7 \
        'cudnnConvolutionBwdDataAlgoPerf_v7_t':  # NOQA: E125
        int algo
        int status
        float time
        size_t memory
        int determinism
        int mathType
    ctypedef int ConvolutionBwdFilterAlgo 'cudnnConvolutionBwdFilterAlgo_t'
    ctypedef int ConvolutionBwdFilterPreference \
        'cudnnConvolutionBwdFilterPreference_t'
    ctypedef struct ConvolutionBwdFilterAlgoPerf \
        'cudnnConvolutionBwdFilterAlgoPerf_t':  # NOQA: E125
        int algo
        int status
        float time
        size_t memory
    ctypedef struct ConvolutionBwdFilterAlgoPerf_v7 \
        'cudnnConvolutionBwdFilterAlgoPerf_v7_t':  # NOQA: E125
        int algo
        int status
        float time
        size_t memory
        int determinism
        int mathType
    ctypedef int ConvolutionFwdAlgo 'cudnnConvolutionFwdAlgo_t'
    ctypedef int ConvolutionFwdPreference 'cudnnConvolutionFwdPreference_t'
    ctypedef struct ConvolutionFwdAlgoPerf 'cudnnConvolutionFwdAlgoPerf_t':
        int algo
        int status
        float time
        size_t memory
    ctypedef struct ConvolutionFwdAlgoPerf_v7 \
        'cudnnConvolutionFwdAlgoPerf_v7_t':  # NOQA: E125
        int algo
        int status
        float time
        size_t memory
        int determinism
        int mathType
    ctypedef int ConvolutionMode 'cudnnConvolutionMode_t'
    ctypedef int DataType 'cudnnDataType_t'
    ctypedef int MathType 'cudnnMathType_t'
    ctypedef int DirectionMode 'cudnnDirectionMode_t'
    ctypedef int NanPropagation 'cudnnNanPropagation_t'
    ctypedef int PoolingMode 'cudnnPoolingMode_t'
    ctypedef int RNNInputMode 'cudnnRNNInputMode_t'
    ctypedef int CTCLossAlgo 'cudnnCTCLossAlgo_t'
    ctypedef int RNNMode 'cudnnRNNMode_t'
    ctypedef int RNNAlgo 'cudnnRNNAlgo_t'
    ctypedef int RNNDataLayout 'cudnnRNNDataLayout_t'
    ctypedef int RNNPaddingMode 'cudnnRNNPaddingMode_t'
    ctypedef int SeqDataAxis 'cudnnSeqDataAxis_t'
    ctypedef int SoftmaxAlgorithm 'cudnnSoftmaxAlgorithm_t'
    ctypedef int SoftmaxMode 'cudnnSoftmaxMode_t'
    ctypedef int Status 'cudnnStatus_t'
    ctypedef int TensorFormat 'cudnnTensorFormat_t'
    ctypedef int OpTensorOp 'cudnnOpTensorOp_t'
    ctypedef int ReduceTensorOp 'cudnnReduceTensorOp_t'
    ctypedef int ReduceTensorIndices 'cudnnReduceTensorIndices_t'
    ctypedef int IndicesType 'cudnnIndicesType_t'
    ctypedef int ErrQueryMode 'cudnnErrQueryMode_t'
    ctypedef struct RuntimeTag 'cudnnRuntimeTag_t'
    ctypedef int WgradMode 'cudnnWgradMode_t'

    ctypedef void* ActivationDescriptor 'cudnnActivationDescriptor_t'
    ctypedef void* AttnDescriptor 'cudnnAttnDescriptor_t'
    ctypedef void* ConvolutionDescriptor 'cudnnConvolutionDescriptor_t'
    ctypedef void* DropoutDescriptor 'cudnnDropoutDescriptor_t'
    ctypedef void* FilterDescriptor 'cudnnFilterDescriptor_t'
    ctypedef void* Handle 'cudnnHandle_t'
    ctypedef void* PoolingDescriptor 'cudnnPoolingDescriptor_t'
    ctypedef void* CTCLossDescriptor 'cudnnCTCLossDescriptor_t'
    ctypedef void* RNNDescriptor 'cudnnRNNDescriptor_t'
    ctypedef void* RNNDataDescriptor 'cudnnRNNDataDescriptor_t'
    ctypedef void* PersistentRNNPlan 'cudnnPersistentRNNPlan_t'
    ctypedef void* SeqDataDescriptor 'cudnnSeqDataDescriptor_t'
    ctypedef void* TensorDescriptor 'cudnnTensorDescriptor_t'
    ctypedef void* OpTensorDescriptor 'cudnnOpTensorDescriptor_t'
    ctypedef void* ReduceTensorDescriptor 'cudnnReduceTensorDescriptor_t'
    ctypedef void* SpatialTransformerDescriptor \
        'cudnnSpatialTransformerDescriptor_t'
    ctypedef void* SamplerType 'cudnnSamplerType_t'

    # Error handling
    const char* cudnnGetErrorString(Status status)

    # Version
    size_t cudnnGetVersion()

    # Runtime error checking
    int cudnnQueryRuntimeError(Handle handle, Status *rstatus,
                               ErrQueryMode mode, RuntimeTag *tag)

    # Initialization and CUDA cooperation
    int cudnnCreate(Handle* handle)
    int cudnnDestroy(Handle handle)
    int cudnnSetStream(Handle handle, driver.Stream stream)
    int cudnnGetStream(Handle handle, driver.Stream* stream)

    # Tensor manipulation
    int cudnnCreateTensorDescriptor(TensorDescriptor* descriptor)
    int cudnnSetTensor4dDescriptor(
        TensorDescriptor tensorDesc, TensorFormat format,
        DataType dataType, int n, int c, int h, int w)
    int cudnnSetTensor4dDescriptorEx(
        TensorDescriptor tensorDesc, DataType dataType,
        int n, int c, int h, int w,
        int nStride, int cStride, int hStride, int wStride)
    int cudnnGetTensor4dDescriptor(
        TensorDescriptor tensorDesc, DataType* dataType,
        int* n, int* c, int* h, int* w,
        int* nStride, int* cStride, int* hStride, int* wStride)
    int cudnnSetTensorNdDescriptor(
        TensorDescriptor tensorDesc, DataType dataType, int nbDims,
        int* dimA, int* strideA)
    int cudnnDestroyTensorDescriptor(TensorDescriptor tensorDesc)
    int cudnnAddTensor_v3(
        Handle handle, void* alpha, TensorDescriptor bDesc,
        void* b, void* beta, TensorDescriptor yDesc, void* y)

    # Tensor operations
    int cudnnCreateOpTensorDescriptor(OpTensorDescriptor* opTensorDesc)
    int cudnnSetOpTensorDescriptor(
        OpTensorDescriptor opTensorDesc, OpTensorOp opTensorOp,
        DataType opTensorCompType, NanPropagation opTensorNanOpt)
    int cudnnGetOpTensorDescriptor(
        OpTensorDescriptor opTensorDesc, OpTensorOp* opTensorOp,
        DataType* opTensorCompType, NanPropagation* opTensorNanOpt)
    int cudnnDestroyOpTensorDescriptor(OpTensorDescriptor opTensorDesc)
    int cudnnOpTensor(
        Handle handle, OpTensorDescriptor opTensorDesc, void* alpha1,
        TensorDescriptor aDesc, void* A, void* alpha2,
        TensorDescriptor bDesc, void* B, void* beta,
        TensorDescriptor cDesc, void* C)

    # Tensor reductions
    int cudnnCreateReduceTensorDescriptor(
        ReduceTensorDescriptor* reduceTensorDesc)
    int cudnnSetReduceTensorDescriptor(
        ReduceTensorDescriptor reduceTensorDesc, ReduceTensorOp reduceTensorOp,
        DataType reduceTensorCompType, NanPropagation reduceTensorNanOpt,
        ReduceTensorIndices reduceTensorIndices,
        IndicesType reduceTensorIndicesType)
    int cudnnGetReduceTensorDescriptor(
        ReduceTensorDescriptor reduceTensorDesc,
        ReduceTensorOp* reduceTensorOp, DataType* reduceTensorCompType,
        NanPropagation* reduceTensorNanOpt,
        ReduceTensorIndices* reduceTensorIndices,
        IndicesType* reduceTensorIndicesType)
    int cudnnDestroyReduceTensorDescriptor(
        ReduceTensorDescriptor reduceTensorDesc)
    int cudnnGetReductionIndicesSize(
        Handle handle, ReduceTensorDescriptor reduceTensorDesc,
        TensorDescriptor aDesc, TensorDescriptor cDesc, size_t* sizeInBytes)
    int cudnnGetReductionWorkspaceSize(
        Handle handle, ReduceTensorDescriptor reduceTensorDesc,
        TensorDescriptor aDesc, TensorDescriptor cDesc, size_t* sizeInBytes)
    int cudnnReduceTensor(
        Handle handle, ReduceTensorDescriptor reduceTensorDesc, void* indices,
        size_t indicesSizeInBytes, void* workspace,
        size_t workspaceSizeInBytes, void* alpha, TensorDescriptor aDesc,
        void* A, void* beta, TensorDescriptor cDesc, void* c)
    int cudnnSetTensor(
        Handle handle, TensorDescriptor yDesc, void* y, void* valuePtr)
    int cudnnScaleTensor(
        Handle handle, TensorDescriptor yDesc, void* y, void* alpha)

    # Filter manipulation
    int cudnnCreateFilterDescriptor(FilterDescriptor* filterDesc)
    int cudnnSetFilter4dDescriptor_v4(
        FilterDescriptor filterDesc, DataType dataType,
        TensorFormat format, int k, int c, int h, int w)
    int cudnnSetFilterNdDescriptor_v4(
        FilterDescriptor filterDesc, DataType dataType,
        TensorFormat format, int nbDims, const int filterDimA[])
    int cudnnGetFilterNdDescriptor_v4(
        FilterDescriptor wDesc, int nbDimsRequested, DataType* dataType,
        TensorFormat* format, int* nbDims, int filterDimA[])
    int cudnnDestroyFilterDescriptor(FilterDescriptor filterDesc)

    # Convolution
    int cudnnCreateConvolutionDescriptor(ConvolutionDescriptor* convDesc)
    int cudnnSetConvolutionMathType(
        ConvolutionDescriptor convDesc, MathType mathType)
    int cudnnGetConvolutionMathType(
        ConvolutionDescriptor convDesc, MathType *mathType)
    int cudnnSetConvolutionGroupCount(
        ConvolutionDescriptor convDesc, int groupCount)
    int cudnnGetConvolutionGroupCount(
        ConvolutionDescriptor convDesc, int *groupCount)
    int cudnnSetConvolution2dDescriptor_v4(
        ConvolutionDescriptor convDesc, int pad_h, int pad_w, int u,
        int v, int dilation_h, int dilation_w, ConvolutionMode mode)
    int cudnnSetConvolution2dDescriptor_v5(
        ConvolutionDescriptor convDesc, int pad_h, int pad_w, int u,
        int v, int dilation_h, int dilation_w, ConvolutionMode mode,
        DataType computeType)
    int cudnnSetConvolutionNdDescriptor_v3(
        ConvolutionDescriptor convDesc, int arrayLength, int* padA,
        int* filterStrideA, int* dilationA, ConvolutionMode mode,
        DataType dataType)
    int cudnnDestroyConvolutionDescriptor(ConvolutionDescriptor conDesc)
    int cudnnFindConvolutionForwardAlgorithm(
        Handle handle, TensorDescriptor xDesc, FilterDescriptor wDesc,
        ConvolutionDescriptor convDesc, TensorDescriptor yDesc,
        int requestedAlgoCount, int* returnedAlgoCount,
        ConvolutionFwdAlgoPerf* perfResults)
    int cudnnFindConvolutionForwardAlgorithmEx(
        Handle handle, TensorDescriptor xDesc, void* x,
        FilterDescriptor wDesc, void* w, ConvolutionDescriptor convDesc,
        TensorDescriptor yDesc, void* y, int requestedAlgoCount,
        int* returnedAlgoCount, ConvolutionFwdAlgoPerf* perfResults,
        void* workSpace, size_t workSpaceSizeInBytes)
    int cudnnFindConvolutionForwardAlgorithmEx_v7(
        Handle handle, TensorDescriptor xDesc, void* x,
        FilterDescriptor wDesc, void* w, ConvolutionDescriptor convDesc,
        TensorDescriptor yDesc, void* y, int requestedAlgoCount,
        int* returnedAlgoCount, ConvolutionFwdAlgoPerf_v7* perfResults,
        void* workSpace, size_t workSpaceSizeInBytes)
    int cudnnGetConvolutionForwardAlgorithm_v6(
        Handle handle, TensorDescriptor srcDesc,
        FilterDescriptor filterDesc, ConvolutionDescriptor convDesc,
        TensorDescriptor destDesc, ConvolutionFwdPreference preference,
        size_t memoryLimitInbytes, ConvolutionFwdAlgo* algo)
    int cudnnGetConvolutionForwardAlgorithm_v7(
        Handle handle, TensorDescriptor srcDesc,
        FilterDescriptor filterDesc, ConvolutionDescriptor convDesc,
        TensorDescriptor destDesc, int requestedAlgoCount,
        int* returnedAlgoCount, ConvolutionFwdAlgoPerf_v7* perfResults)
    int cudnnGetConvolutionForwardWorkspaceSize(
        Handle handle, TensorDescriptor srcDesc,
        FilterDescriptor filterDesc, ConvolutionDescriptor convDesc,
        TensorDescriptor destDesc, ConvolutionFwdAlgo algo,
        size_t* sizeInBytes)
    int cudnnConvolutionForward(
        Handle handle, void* alpha, TensorDescriptor srcDesc,
        void* srcData, FilterDescriptor filterDesc, void* filterData,
        ConvolutionDescriptor convDesc, ConvolutionFwdAlgo algo,
        void* workSpace, size_t workSpaceSizeInBytes, void* beta,
        TensorDescriptor destDesc, void* destData)
    int cudnnConvolutionBackwardBias(
        Handle handle, void* alpha,
        TensorDescriptor srcDesc, void* srcData, void* beta,
        TensorDescriptor destDesc, void* destData)
    int cudnnFindConvolutionBackwardFilterAlgorithm(
        Handle handle, TensorDescriptor xDesc, TensorDescriptor dyDesc,
        ConvolutionDescriptor convDesc, FilterDescriptor dwDesc,
        int requestedAlgoCount, int* returnedAlgoCount,
        ConvolutionBwdFilterAlgoPerf* perfResults)
    int cudnnFindConvolutionBackwardFilterAlgorithmEx(
        Handle handle, TensorDescriptor xDesc, void* x,
        TensorDescriptor dyDesc, void* dy, ConvolutionDescriptor convDesc,
        FilterDescriptor dwDesc, void* dw, int requestedAlgoCount,
        int* returnedAlgoCount, ConvolutionBwdFilterAlgoPerf* perfResults,
        void* workSpace, size_t workSpaceSizeInBytes)
    int cudnnFindConvolutionBackwardFilterAlgorithmEx_v7(
        Handle handle, TensorDescriptor xDesc, void* x,
        TensorDescriptor dyDesc, void* dy, ConvolutionDescriptor convDesc,
        FilterDescriptor dwDesc, void* dw, int requestedAlgoCount,
        int* returnedAlgoCount, ConvolutionBwdFilterAlgoPerf_v7* perfResults,
        void* workSpace, size_t workSpaceSizeInBytes)
    int cudnnGetConvolutionBackwardFilterAlgorithm_v6(
        Handle handle, TensorDescriptor srcDesc, TensorDescriptor diffDesc,
        ConvolutionDescriptor convDesc, FilterDescriptor filterDesc,
        ConvolutionBwdFilterPreference preference,
        size_t memoryLimitInbytes, ConvolutionBwdFilterAlgo* algo)
    int cudnnGetConvolutionBackwardFilterAlgorithm_v7(
        Handle handle, TensorDescriptor srcDesc, TensorDescriptor diffDesc,
        ConvolutionDescriptor convDesc, FilterDescriptor gradDesc,
        int requestedAlgoCount, int* returnedAlgoCount,
        ConvolutionBwdFilterAlgoPerf_v7* perfResults)
    int cudnnGetConvolutionBackwardFilterWorkspaceSize(
        Handle handle, TensorDescriptor srcDesc, TensorDescriptor diffDesc,
        ConvolutionDescriptor convDesc, FilterDescriptor filterDesc,
        ConvolutionBwdFilterAlgo algo, size_t* sizeInBytes)
    int cudnnConvolutionBackwardFilter_v3(
        Handle handle, void* alpha,
        TensorDescriptor srcDesc, void* srcData,
        TensorDescriptor diffDesc, void* diffData,
        ConvolutionDescriptor convDesc, ConvolutionBwdFilterAlgo algo,
        void* workSpace, size_t workSpaceSizeInBytes, void* beta,
        FilterDescriptor gradDesc, void* gradData)
    int cudnnGetConvolutionBackwardDataAlgorithm_v6(
        Handle handle, FilterDescriptor filterDesc,
        TensorDescriptor diffDesc,
        ConvolutionDescriptor convDesc, TensorDescriptor gradDesc,
        ConvolutionBwdDataPreference preference,
        size_t memoryLimitInbytes, ConvolutionBwdDataAlgo* algo)
    int cudnnGetConvolutionBackwardDataAlgorithm_v7(
        Handle handle, TensorDescriptor filterDesc, TensorDescriptor diffDesc,
        ConvolutionDescriptor convDesc, FilterDescriptor gradDesc,
        int requestedAlgoCount, int* returnedAlgoCount,
        ConvolutionBwdDataAlgoPerf_v7* perfResults)
    int cudnnFindConvolutionBackwardDataAlgorithm(
        Handle handle, TensorDescriptor wDesc, TensorDescriptor dyDesc,
        ConvolutionDescriptor convDesc, FilterDescriptor dxDesc,
        int requestedAlgoCount, int* returnedAlgoCount,
        ConvolutionBwdDataAlgoPerf* perfResults)
    int cudnnFindConvolutionBackwardDataAlgorithmEx(
        Handle handle, FilterDescriptor wDesc, void* w,
        TensorDescriptor dyDesc, void* dy, ConvolutionDescriptor convDesc,
        TensorDescriptor dxDesc, void* dx, int requestedAlgoCount,
        int* returnedAlgoCount, ConvolutionBwdDataAlgoPerf* perfResults,
        void* workSpace, size_t workSpaceSizeInBytes)
    int cudnnFindConvolutionBackwardDataAlgorithmEx_v7(
        Handle handle, FilterDescriptor wDesc, void* w,
        TensorDescriptor dyDesc, void* dy, ConvolutionDescriptor convDesc,
        TensorDescriptor dxDesc, void* dx, int requestedAlgoCount,
        int* returnedAlgoCount, ConvolutionBwdDataAlgoPerf_v7* perfResults,
        void* workSpace, size_t workSpaceSizeInBytes)
    int cudnnGetConvolutionBackwardDataWorkspaceSize(
        Handle handle, FilterDescriptor filterDesc,
        TensorDescriptor diffDesc,
        ConvolutionDescriptor convDesc, TensorDescriptor gradDesc,
        ConvolutionBwdDataAlgo algo, size_t* sizeInBytes)
    int cudnnConvolutionBackwardData_v3(
        Handle handle, void* alpha,
        FilterDescriptor filterDesc, void* filterData,
        TensorDescriptor diffDesc, void* diffData,
        ConvolutionDescriptor convDesc, ConvolutionBwdDataAlgo algo,
        void* workSpace, size_t workSpaceSizeInBytes, void* beta,
        TensorDescriptor gradDesc, void* gradData)

    # Pooling
    int cudnnCreatePoolingDescriptor(PoolingDescriptor* desc)
    int cudnnSetPooling2dDescriptor_v4(
        PoolingDescriptor poolingDesc, PoolingMode mode,
        NanPropagation maxpoolingNanOpt, int windowHeight, int windowWidth,
        int verticalPadding, int horizontalPadding, int verticalStride,
        int horizontalStride)
    int cudnnSetPoolingNdDescriptor_v4(
        PoolingDescriptor poolingDesc, PoolingMode mode,
        NanPropagation maxpoolingNanOpt, int nbDims,
        int* windowDimA, int* paddingA, int* strideA)
    int cudnnDestroyPoolingDescriptor(PoolingDescriptor poolingDesc)
    int cudnnPoolingForward(
        Handle handle, PoolingDescriptor poolingDesc, void* alpha,
        TensorDescriptor srcDesc, void* srcData, void* beta,
        TensorDescriptor dstDesc, void* dstData)
    int cudnnPoolingBackward(
        Handle handle, PoolingDescriptor poolingDesc, void* alpha,
        TensorDescriptor srcDesc, void* srcData,
        TensorDescriptor srcDiffDesc, void* srcDiffData,
        TensorDescriptor destDesc, void* destData, void* beta,
        TensorDescriptor destDiffDesc, void* destDiffData)

    # Batch Normalization
    int cudnnDeriveBNTensorDescriptor(
        TensorDescriptor derivedBnDesc, TensorDescriptor xDesc,
        BatchNormMode mode)
    int cudnnBatchNormalizationForwardTraining(
        Handle handle, BatchNormMode mode,
        void* alpha, void* beta, TensorDescriptor xDesc,
        void* x, TensorDescriptor yDesc, void* y,
        TensorDescriptor bnScaleBiasMeanVarDesc, void* bnScale,
        void* bnBias, double exponentialAverageFactor,
        void* resultRunningMean, void* resultRunningVariance,
        double epsilon, void* resultSaveMean,
        void* resultSaveInvVariance)
    int cudnnBatchNormalizationForwardInference(
        Handle handle, BatchNormMode mode,
        void* alpha, void* beta, TensorDescriptor xDesc,
        void* x, TensorDescriptor yDesc, void* y,
        TensorDescriptor bnScaleBiasMeanVarDesc, void* bnScale,
        void* bnBias, void* estimatedMean, void* estimatedVariance,
        double epsilon)
    int cudnnBatchNormalizationBackward(
        Handle handle, BatchNormMode mode,
        void* alphaDataDiff, void* betaDataDiff,
        void* alphaParamDiff, void* betaParamDiff,
        TensorDescriptor xDesc, void* x,
        TensorDescriptor dyDesc, void* dy,
        TensorDescriptor dxDesc, void* dx,
        TensorDescriptor dBnScaleBiasDesc, void* bnScale,
        void* dBnScaleResult, void* dBnBiasResult,
        double epsilon, void* savedMean, void* savedInvVariance)

    int cudnnBatchNormalizationForwardTrainingEx(
        Handle handle,
        BatchNormMode mode, BatchNormOps bnOps,
        void* alpha, void* beta,
        TensorDescriptor xDesc, void* x,
        TensorDescriptor zDesc, void* z,
        TensorDescriptor yDesc, void* y,
        TensorDescriptor bnScaleBiasMeanVarDesc,
        void* bnScale, void* bnBias,
        double exponentialAverageFactor,
        void* resultRunningMean, void* resultRunningVariance,
        double epsilon,
        void* resultSaveMean, void* resultSaveInvVariance,
        ActivationDescriptor activationDesc,
        void* workspace, size_t workSpaceSizeInBytes,
        void* reserveSpace, size_t reserveSpaceSizeInBytes)
    int cudnnGetBatchNormalizationForwardTrainingExWorkspaceSize(
        Handle handle,
        BatchNormMode mode, BatchNormOps bnOps,
        TensorDescriptor xDesc,
        TensorDescriptor zDesc,
        TensorDescriptor yDesc,
        TensorDescriptor bnScaleBiasMeanVarDesc,
        ActivationDescriptor activationDesc,
        size_t* sizeInBytes)
    int cudnnBatchNormalizationBackwardEx(
        Handle handle,
        BatchNormMode mode, BatchNormOps bnops,
        void* alphaDataDiff, void* betaDataDiff,
        void* alphaParamDiff, void* betaParamDiff,
        TensorDescriptor xDesc, void* x,
        TensorDescriptor yDesc, void* y,
        TensorDescriptor dyDesc, void* dy,
        TensorDescriptor dzDesc, void* dz,
        TensorDescriptor dxDesc, void* dx,
        TensorDescriptor dBnScaleBiasDesc,
        void* bnScaleData, void* bnBiasData,
        void* dBnScaleData, void* dBnBiasData,
        double epsilon,
        void* savedMean, void* savedInvVariance,
        ActivationDescriptor activationDesc,
        void* workspace, size_t workSpaceSizeInBytes,
        void* reserveSpace, size_t reserveSpaceSizeInBytes)
    int cudnnGetBatchNormalizationBackwardExWorkspaceSize(
        Handle handle,
        BatchNormMode mode,
        BatchNormOps bnOps,
        TensorDescriptor xDesc,
        TensorDescriptor yDesc,
        TensorDescriptor dyDesc,
        TensorDescriptor dzDesc,
        TensorDescriptor dxDesc,
        TensorDescriptor dBnScaleBiasDesc,
        ActivationDescriptor activationDesc,
        size_t* sizeInBytes)
    int cudnnGetBatchNormalizationTrainingExReserveSpaceSize(
        Handle handle,
        BatchNormMode mode,
        BatchNormOps bnOps,
        ActivationDescriptor activationDesc,
        TensorDescriptor xDesc,
        size_t* sizeInBytes)

    # Activation
    int cudnnCreateActivationDescriptor(
        ActivationDescriptor* activationDesc)
    int cudnnSetActivationDescriptor(
        ActivationDescriptor activationDesc, ActivationMode mode,
        NanPropagation reluNanOpt, double reluCeiling)
    int cudnnDestroyActivationDescriptor(
        ActivationDescriptor activationDesc)
    int cudnnSoftmaxForward(
        Handle handle, SoftmaxAlgorithm algorithm, SoftmaxMode mode,
        void* alpha, TensorDescriptor srcDesc, void* srcData,
        void* beta, TensorDescriptor dstDesc, void* dstData)
    int cudnnSoftmaxBackward(
        Handle handle, SoftmaxAlgorithm algorithm, SoftmaxMode mode,
        void* alpha, TensorDescriptor srcDesc, void* srcData,
        TensorDescriptor srcDiffDesc, void* srcDiffData, void* beta,
        TensorDescriptor destDiffDesc, void* destDiffData)
    int cudnnActivationForward_v4(
        Handle handle, ActivationDescriptor activationDesc, void* alpha,
        TensorDescriptor srcDesc, void* srcData, void* beta,
        TensorDescriptor dstDesc, void* dstData)
    int cudnnActivationBackward_v4(
        Handle handle, ActivationDescriptor activationDesc, void* alpha,
        TensorDescriptor srcDesc, void* srcData,
        TensorDescriptor srcDiffDesc, void* srcDiffData,
        TensorDescriptor destDesc, void* destData, void* beta,
        TensorDescriptor destDiffDesc, void* destDiffData)

    # Dropout
    int cudnnCreateDropoutDescriptor(DropoutDescriptor* desc)
    int cudnnDestroyDropoutDescriptor(DropoutDescriptor dropoutDesc)
    int cudnnDropoutGetStatesSize(Handle handle, size_t* sizeInBytes)
    int cudnnDropoutGetReserveSpaceSize(
        TensorDescriptor xDesc, size_t* sizeInBytes)
    int cudnnSetDropoutDescriptor(
        DropoutDescriptor dropoutDesc, Handle handle, float dropout,
        void* states, size_t stateSizeInBytes, unsigned long long seed)
    int cudnnDropoutForward(
        Handle handle, DropoutDescriptor dropoutDesc,
        TensorDescriptor srcDesc, void* srcData,
        TensorDescriptor dstDesc, void* dstData,
        void* reserveSpace, size_t reserveSpaceSizeInBytes)
    int cudnnDropoutBackward(
        Handle handle, DropoutDescriptor dropoutDesc,
        TensorDescriptor dydesc, void* dy, TensorDescriptor dxdesc,
        void* dx, void* reserveSpace, size_t reserveSpaceSizeInBytes)

    # CTC
    int cudnnCreateCTCLossDescriptor(CTCLossDescriptor* ctcLossDesc)
    int cudnnDestroyCTCLossDescriptor(CTCLossDescriptor ctcLossDesc)
    int cudnnSetCTCLossDescriptor(
        CTCLossDescriptor ctcLossDesc, DataType dataType)
    int cudnnGetCTCLossDescriptor(
        CTCLossDescriptor ctcLossDesc, DataType* dataType)
    int cudnnGetCTCLossWorkspaceSize(
        Handle handle, TensorDescriptor probsDesc,
        TensorDescriptor gradientsDesc, int* labels,
        int* labelLengths, int* inputLengths, CTCLossAlgo algo,
        CTCLossDescriptor ctcLossDesc, size_t* sizeInBytes)
    int cudnnCTCLoss(
        Handle handle, TensorDescriptor probsDesc,
        void* probs, int* labels, int* labelLengths, int* inputLengths,
        void* costs, TensorDescriptor gradientsDesc, void* gradients,
        CTCLossAlgo algo, CTCLossDescriptor ctcLossDesc,
        void* workspace, size_t workSpaceSizeInBytes)
    # RNN
    int cudnnCreateRNNDescriptor(RNNDescriptor* rnnDesc)
    int cudnnDestroyRNNDescriptor(RNNDescriptor rnnDesc)
    int cudnnCreatePersistentRNNPlan(
        RNNDescriptor rnnDesc,
        const int minibatch, DataType dataType,
        PersistentRNNPlan* plan)
    int cudnnSetPersistentRNNPlan(
        RNNDescriptor rnnDesc, PersistentRNNPlan plan)
    int cudnnDestroyPersistentRNNPlan(PersistentRNNPlan plan)
    int cudnnSetRNNDescriptor_v5(
        RNNDescriptor rnnDesc, int hiddenSize,
        int numLayers, DropoutDescriptor dropoutDesc, RNNInputMode inputMode,
        DirectionMode direction, RNNMode mode, DataType dataType)
    int cudnnSetRNNDescriptor_v6(
        Handle handle, RNNDescriptor rnnDesc, int hiddenSize,
        int numLayers, DropoutDescriptor dropoutDesc, RNNInputMode inputMode,
        DirectionMode direction, RNNMode mode, RNNAlgo algo, DataType dataType)
    int cudnnSetRNNPaddingMode(
        RNNDescriptor rnnDesc, RNNPaddingMode paddingMode)
    int cudnnGetRNNPaddingMode(
        RNNDescriptor rnnDesc, RNNPaddingMode* paddingMode)
    int cudnnCreateRNNDataDescriptor(RNNDataDescriptor* RNNDataDesc)
    int cudnnDestroyRNNDataDescriptor(RNNDataDescriptor RNNDataDesc)
    int cudnnSetRNNDataDescriptor(
        RNNDataDescriptor RNNDataDesc, DataType dataType, RNNDataLayout layout,
        int maxSeqLength, int batchSize, int vectorSize,
        const int seqLengthArray[], void *paddingFill)
    int cudnnGetRNNDataDescriptor(
        RNNDataDescriptor RNNDataDesc, DataType* dataType,
        RNNDataLayout* layout, int* maxSeqLength, int* batchSize,
        int* vectorSize, int arrayLengthRequested, int seqLengthArray[],
        void* paddingFill)
    int cudnnGetRNNWorkspaceSize(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* xDesc, size_t* sizeInBytes)
    int cudnnGetRNNTrainingReserveSize(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* xDesc, size_t* sizeInBytes)
    int cudnnGetRNNParamsSize(
        Handle handle, RNNDescriptor rnnDesc, TensorDescriptor xDesc,
        size_t* sizeInBytes, DataType dataType)
    int cudnnGetRNNLinLayerMatrixParams(
        Handle handle, RNNDescriptor rnnDesc, int layer,
        TensorDescriptor xDesc, FilterDescriptor wDesc, void* w,
        int linLayerID, FilterDescriptor linLayerMatDesc,
        void** linLayerMat)
    int cudnnGetRNNLinLayerBiasParams(
        Handle handle, RNNDescriptor rnnDesc, int layer,
        TensorDescriptor xDesc, FilterDescriptor wDesc, void* w,
        int linLayerID, FilterDescriptor linLayerBiasDesc,
        void** linLayerBias)
    int cudnnRNNForwardInference(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* xDesc,
        void* x, TensorDescriptor hxDesc, void* hx, TensorDescriptor cxDesc,
        void* cx, FilterDescriptor wDesc, void* w, TensorDescriptor* yDesc,
        void* y, TensorDescriptor hyDesc, void* hy, TensorDescriptor cyDesc,
        void* cy, void* workspace, size_t workSpaceSizeInBytes)
    int cudnnRNNForwardTraining(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* xDesc, void* x,
        TensorDescriptor hxDesc, void* hx, TensorDescriptor cxDesc, void* cx,
        FilterDescriptor wDesc, void* w, TensorDescriptor* yDesc, void* y,
        TensorDescriptor hyDesc, void* hy, TensorDescriptor cyDesc, void* cy,
        void* workspace, size_t workSpaceSizeInBytes, void* reserveSpace,
        size_t reserveSpaceSizeInBytes)
    int cudnnRNNBackwardData(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* yDesc, void* y,
        TensorDescriptor* dyDesc, void* dy,
        TensorDescriptor dhyDesc, void* dhy,
        TensorDescriptor dcyDesc, void* dcy,
        FilterDescriptor wDesc, void* w,
        TensorDescriptor hxDesc, void* hx,
        TensorDescriptor cxDesc, void* cx,
        TensorDescriptor* dxDesc, void* dx,
        TensorDescriptor dhxDesc, void* dhx,
        TensorDescriptor dcxDesc, void* dcx, void* workspace,
        size_t workSpaceSizeInBytes, void* reserveSpace,
        size_t reserveSpaceSizeInBytes)
    int cudnnRNNBackwardWeights(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* xDesc, void* x, TensorDescriptor hxDesc, void* hx,
        TensorDescriptor* yDesc, void* y,
        void* workspace, size_t workSpaceSizeInBytes, FilterDescriptor dwDesc,
        void* dw, void* reserveSpace, size_t reserveSpaceSizeInBytes)

    int cudnnRNNForwardInferenceEx(
        Handle handle, RNNDescriptor rnnDesc,
        RNNDataDescriptor xDesc, const void* x,
        TensorDescriptor hxDesc, const void* hx,
        TensorDescriptor cxDesc, const void* cx,
        FilterDescriptor wDesc, const void* w,
        RNNDataDescriptor yDesc, void* y,
        TensorDescriptor hyDesc, void* hy,
        TensorDescriptor cyDesc, void* cy,
        RNNDataDescriptor kDesc, const void* keys,
        RNNDataDescriptor cDesc, void* cAttn,
        RNNDataDescriptor iDesc, void* iAttn,
        RNNDataDescriptor qDesc, void* queries,
        void* workSpace, size_t workSpaceSizeInBytes)
    int cudnnRNNForwardTrainingEx(
        Handle handle, RNNDescriptor rnnDesc,
        RNNDataDescriptor xDesc, const void* x,
        TensorDescriptor hxDesc, const void* hx,
        TensorDescriptor cxDesc, const void* cx,
        FilterDescriptor wDesc, const void* w,
        RNNDataDescriptor yDesc, void* y,
        TensorDescriptor hyDesc, void* hy,
        TensorDescriptor cyDesc, void* cy,
        RNNDataDescriptor kDesc, const void* keys,
        RNNDataDescriptor cDesc, void* cAttn,
        RNNDataDescriptor iDesc, void* iAttn,
        RNNDataDescriptor qDesc, void* queries,
        void* workSpace, size_t workSpaceSizeInBytes,
        void* reserveSpace, size_t reserveSpaceSizeInBytes)
    int cudnnRNNBackwardDataEx(
        Handle handle, RNNDescriptor rnnDesc,
        RNNDataDescriptor yDesc, const void* y,
        RNNDataDescriptor dyDesc, const void* dy,
        RNNDataDescriptor dcDesc, const void* dcAttn,
        TensorDescriptor dhyDesc, const void* dhy,
        TensorDescriptor dcyDesc, const void* dcy,
        FilterDescriptor wDesc, const void* w,
        TensorDescriptor hxDesc, const void* hx,
        TensorDescriptor cxDesc, const void* cx,
        RNNDataDescriptor dxDesc, void* dx,
        TensorDescriptor dhxDesc, void* dhx,
        TensorDescriptor dcxDesc, void* dcx,
        RNNDataDescriptor dkDesc, void* dkeys,
        void* workSpace, size_t workSpaceSizeInBytes,
        void* reserveSpace, size_t reserveSpaceSizeInBytes)
    int cudnnRNNBackwardWeightsEx(
        Handle handle, RNNDescriptor rnnDesc,
        RNNDataDescriptor xDesc, const void* x,
        TensorDescriptor hxDesc, const void* hx,
        RNNDataDescriptor yDesc, const void* y,
        void* workSpace, size_t workSpaceSizeInBytes,
        FilterDescriptor dwDesc, void* dw,
        void* reserveSpace, size_t reserveSpaceSizeInBytes)

    # Spatial Transformer
    int cudnnCreateSpatialTransformerDescriptor(
        SpatialTransformerDescriptor* stDesc)
    int cudnnDestroySpatialTransformerDescriptor(
        SpatialTransformerDescriptor stDesc)
    int cudnnSetSpatialTransformerNdDescriptor(
        SpatialTransformerDescriptor stDesc, SamplerType samplerType,
        DataType dataType, int nbDims, int dimA[])
    int cudnnSpatialTfGridGeneratorForward(
        Handle handle, SpatialTransformerDescriptor stDesc,
        void* theta, void* grid)
    int cudnnSpatialTfGridGeneratorBackward(
        Handle handle, SpatialTransformerDescriptor stDesc,
        void* dgrid, void* dtheta)
    int cudnnSpatialTfSamplerForward(
        Handle handle, SpatialTransformerDescriptor stDesc,
        void* alpha, TensorDescriptor xDesc, void* x,
        void* grid, void* beta, TensorDescriptor yDesc, void* y)
    int cudnnSpatialTfSamplerBackward(
        Handle handle, SpatialTransformerDescriptor stDesc,
        void* alpha, TensorDescriptor xDesc, void* x, void* beta,
        TensorDescriptor dxDesc, void* dx, void* alphaDgrid,
        TensorDescriptor dyDesc, void* dy, void* grid,
        void* betaDgrid, void* dgrid)

    # Multi-head attention
    int cudnnCreateAttnDescriptor(AttnDescriptor* attnDesc)
    int cudnnDestroyAttnDescriptor(AttnDescriptor attnDesc)
    int cudnnGetAttnDescriptor(
        AttnDescriptor attnDesc, AttnQueryMap* queryMap,
        int* nHeads, double* smScaler, DataType* dataType,
        DataType* computePrec, MathType* mathType,
        DropoutDescriptor* attnDropoutDesc,
        DropoutDescriptor* postDropoutDesc,
        int* qSize, int* kSize, int* vSize, int* qProjSize,
        int* kProjSize, int* vProjSize, int* oProjSize,
        int* qoMaxSeqLength, int* kvMaxSeqLength,
        int* maxBatchSize, int* maxBeamSize)
    int cudnnGetMultiHeadAttnBuffers(
        Handle handle, const AttnDescriptor attnDesc,
        size_t* weightSizeInBytes, size_t* workSpaceSizeInBytes,
        size_t* reserveSpaceSizeInBytes)
    int cudnnGetMultiHeadAttnWeights(
        Handle handle, const AttnDescriptor attnDesc,
        MultiHeadAttnWeightKind wKind, size_t weightSizeInBytes,
        const void* w, TensorDescriptor wDesc,
        void** wAddr)
    int cudnnMultiHeadAttnBackwardData(
        Handle handle, const AttnDescriptor attnDesc,
        const int* loWinIdx, const int* hiWinIdx,
        const int* seqLengthArrayDQDO, const int* seqLengthArrayDKDV,
        const SeqDataDescriptor doDesc, const void* dout,
        const SeqDataDescriptor dqDesc, void* dqueries,
        const void* queries, const SeqDataDescriptor dkDesc,
        void* dkeys, const void* keys,
        const SeqDataDescriptor dvDesc, void* dvalues,
        const void* values, size_t weightSizeInBytes,
        const void* w, size_t workSpaceSizeInBytes,
        void* workSpace, size_t reserveSpaceSizeInBytes,
        void* reserveSpace)
    int cudnnMultiHeadAttnBackwardWeights(
        Handle handle, const AttnDescriptor attnDesc,
        WgradMode addGrad, const SeqDataDescriptor qDesc,
        const void* queries, const SeqDataDescriptor kDesc,
        const void* keys, const SeqDataDescriptor vDesc,
        const void* values, const SeqDataDescriptor doDesc,
        const void* dout, size_t weightSizeInBytes,
        const void* w, void* dw,
        size_t workSpaceSizeInBytes, void* workSpace,
        size_t reserveSpaceSizeInBytes, void* reserveSpace)
    int cudnnMultiHeadAttnForward(
        Handle handle, const AttnDescriptor attnDesc,
        int currIdx, const int* loWinIdx,
        const int* hiWinIdx, const int* seqLengthArrayQRO,
        const int* seqLengthArrayKV, const SeqDataDescriptor qDesc,
        const void* queries, const void* residuals,
        const SeqDataDescriptor kDesc, const void* keys,
        const SeqDataDescriptor vDesc, const void* values,
        const SeqDataDescriptor oDesc, void* out,
        size_t weightSizeInBytes, const void* w,
        size_t workSpaceSizeInBytes, void* workSpace,
        size_t reserveSpaceSizeInBytes, void* reserveSpace)
    int cudnnSetAttnDescriptor(
        AttnDescriptor attnDesc, AttnQueryMap queryMap,
        int nHeads, double smScaler,
        DataType dataType, DataType computePrec,
        MathType mathType, DropoutDescriptor attnDropoutDesc,
        DropoutDescriptor postDropoutDesc,
        int qSize, int kSize, int vSize, int qProjSize,
        int kProjSize, int vProjSize, int oProjSize,
        int qoMaxSeqLength, int kvMaxSeqLength,
        int maxBatchSize, int maxBeamSize)
    int cudnnCreateSeqDataDescriptor(
        SeqDataDescriptor* seqDataDesc)
    int cudnnDestroySeqDataDescriptor(SeqDataDescriptor seqDataDesc)
    int cudnnGetSeqDataDescriptor(
        const SeqDataDescriptor seqDataDesc,
        DataType* dataType,
        int* nbDims,
        int nbDimsRequested,
        int dimA[],
        SeqDataAxis axes[],
        size_t* seqLengthArraySize,
        size_t seqLengthSizeRequsted,
        int seqLengthArray[],
        void* paddingFill)
    int cudnnSetSeqDataDescriptor(
        SeqDataDescriptor seqDataDesc,
        DataType dataType,
        int nbDims,
        const int dimA[],
        const SeqDataAxis axes[],
        size_t seqLengthArraySize,
        const int seqLengthArray[],
        void* paddingFill)

    # Build-time version
    int CUDNN_VERSION

    # Constants
    double _CUDNN_BN_MIN_EPSILON 'CUDNN_BN_MIN_EPSILON'


cdef class CuDNNAlgoPerf:

    def __init__(self, algo, status, time, memory, determinism, mathType):
        self.algo = algo
        self.status = status
        self.time = time
        self.memory = memory
        self.determinism = determinism
        self.mathType = mathType


###############################################################################
# Error handling
###############################################################################

class CuDNNError(RuntimeError):

    def __init__(self, int status):
        self.status = status
        msg = cudnnGetErrorString(<Status>status)
        super(CuDNNError, self).__init__(msg.decode())


@cython.profile(False)
cpdef inline check_status(int status):
    if status != 0:
        raise CuDNNError(status)


###############################################################################
# Build-time version
###############################################################################

def get_build_version():
    return CUDNN_VERSION


###############################################################################
# Version
###############################################################################

cpdef size_t getVersion() except? 0:
    return cudnnGetVersion()


###############################################################################
# Runtime error checking
###############################################################################

cpdef queryRuntimeError(size_t handle, int mode):
    cdef Status rstatus
    with nogil:
        status = cudnnQueryRuntimeError(<Handle>handle, &rstatus,
                                        <ErrQueryMode>mode, <RuntimeTag*>0)
    check_status(status)
    return rstatus


###############################################################################
# Initialization and CUDA cooperation
###############################################################################

cpdef size_t create() except? 0:
    cdef Handle handle
    with nogil:
        status = cudnnCreate(&handle)
    check_status(status)
    return <size_t>handle


cpdef destroy(size_t handle):
    with nogil:
        status = cudnnDestroy(<Handle>handle)
    check_status(status)


cpdef setStream(size_t handle, size_t stream):
    status = cudnnSetStream(<Handle>handle, <driver.Stream>stream)
    check_status(status)


cpdef size_t getStream(size_t handle) except? 0:
    cdef driver.Stream stream
    status = cudnnGetStream(<Handle>handle, &stream)
    check_status(status)
    return <size_t>stream


###############################################################################
# Tensor manipulation
###############################################################################

cpdef size_t createTensorDescriptor() except? 0:
    cdef TensorDescriptor descriptor
    status = cudnnCreateTensorDescriptor(&descriptor)
    check_status(status)
    return <size_t>descriptor


cpdef setTensor4dDescriptor(size_t tensorDesc, int format, int dataType,
                            int n, int c, int h, int w):
    status = cudnnSetTensor4dDescriptor(
        <TensorDescriptor>tensorDesc, <TensorFormat>format,
        <DataType>dataType, n, c, h, w)
    check_status(status)


cpdef setTensor4dDescriptorEx(size_t tensorDesc, int dataType,
                              int n, int c, int h, int w, int nStride,
                              int cStride, int hStride, int wStride):
    status = cudnnSetTensor4dDescriptorEx(
        <TensorDescriptor>tensorDesc, <DataType>dataType, n, c, h, w,
        nStride, cStride, hStride, wStride)
    check_status(status)


cpdef tuple getTensor4dDescriptor(size_t tensorDesc):
    cdef DataType dataType
    cdef int n, c, h, w, nStride, cStride, hStride, wStride
    status = cudnnGetTensor4dDescriptor(
        <TensorDescriptor>tensorDesc, &dataType,
        &n, &c, &h, &w, &nStride, &cStride, &hStride, &wStride)
    check_status(status)
    return dataType, n, c, h, w, nStride, cStride, hStride, wStride


cpdef setTensorNdDescriptor(size_t tensorDesc, int dataType, int nbDims,
                            size_t dimA, size_t strideA):
    status = cudnnSetTensorNdDescriptor(
        <TensorDescriptor>tensorDesc, <DataType>dataType, nbDims,
        <int*>dimA, <int*>strideA)
    check_status(status)


cpdef destroyTensorDescriptor(size_t tensorDesc):
    status = cudnnDestroyTensorDescriptor(<TensorDescriptor>tensorDesc)
    check_status(status)


cpdef addTensor_v3(size_t handle, size_t alpha, size_t bDesc,
                   size_t b, size_t beta, size_t yDesc, size_t y):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnAddTensor_v3(
            <Handle>handle, <void*>alpha, <TensorDescriptor>bDesc,
            <void*>b, <void*>beta, <TensorDescriptor>yDesc, <void*>y)
    check_status(status)


###############################################################################
# Tensor operations
###############################################################################

cpdef size_t createOpTensorDescriptor() except? 0:
    cdef OpTensorDescriptor opTensorDesc
    status = cudnnCreateOpTensorDescriptor(&opTensorDesc)
    check_status(status)
    return <size_t>opTensorDesc


cpdef setOpTensorDescriptor(size_t opTensorDesc, int opTensorOp,
                            int opTensorCompType, int opTensorNanOpt):
    status = cudnnSetOpTensorDescriptor(
        <OpTensorDescriptor>opTensorDesc, <OpTensorOp>opTensorOp,
        <DataType>opTensorCompType, <NanPropagation>opTensorNanOpt)
    check_status(status)


cpdef getOpTensorDescriptor(size_t opTensorDesc):
    cdef OpTensorOp opTensorOp
    cdef DataType opTensorCompType
    cdef NanPropagation opTensorNanOpt
    status = cudnnGetOpTensorDescriptor(
        <OpTensorDescriptor>opTensorDesc, &opTensorOp, &opTensorCompType,
        &opTensorNanOpt)
    check_status(status)
    return opTensorOp, opTensorCompType, opTensorNanOpt


cpdef destroyOpTensorDescriptor(size_t opTensorDesc):
    status = cudnnDestroyOpTensorDescriptor(<OpTensorDescriptor>opTensorDesc)
    check_status(status)


cpdef opTensor(size_t handle, size_t opTensorDesc, size_t alpha1,
               size_t aDesc, size_t A, size_t alpha2, size_t bDesc,
               size_t B, size_t beta, size_t cDesc, size_t C):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnOpTensor(
            <Handle>handle, <OpTensorDescriptor>opTensorDesc, <void*>alpha1,
            <TensorDescriptor>aDesc, <void*>A, <void*>alpha2,
            <TensorDescriptor>bDesc, <void*>B, <void*>beta,
            <TensorDescriptor>cDesc, <void*>C)
    check_status(status)


###############################################################################
# Tensor reductions
###############################################################################

cpdef size_t createReduceTensorDescriptor() except? 0:
    cdef ReduceTensorDescriptor reduceTensorDesc
    status = cudnnCreateReduceTensorDescriptor(&reduceTensorDesc)
    check_status(status)
    return <size_t>reduceTensorDesc

cpdef setReduceTensorDescriptor(
        size_t reduceTensorDesc, int reduceTensorOp, int reduceTensorCompType,
        int reduceTensorNanOpt, int reduceTensorIndices,
        int reduceTensorIndicesType):
    status = cudnnSetReduceTensorDescriptor(
        <ReduceTensorDescriptor>reduceTensorDesc,
        <ReduceTensorOp>reduceTensorOp,
        <DataType>reduceTensorCompType, <NanPropagation>reduceTensorNanOpt,
        <ReduceTensorIndices>reduceTensorIndices,
        <IndicesType>reduceTensorIndicesType)
    check_status(status)


cpdef getReduceTensorDescriptor(size_t reduceTensorDesc):
    cdef ReduceTensorOp redOp
    cdef DataType redCompType
    cdef NanPropagation redNanOpt
    cdef ReduceTensorIndices redIndices
    cdef IndicesType redIndicesType
    status = cudnnGetReduceTensorDescriptor(
        <ReduceTensorDescriptor>reduceTensorDesc, &redOp,
        &redCompType, &redNanOpt, &redIndices, &redIndicesType)
    check_status(status)
    return redOp, redCompType, redNanOpt, redIndices, redIndicesType


cpdef destroyReduceTensorDescriptor(size_t reduceTensorDesc):
    status = cudnnDestroyReduceTensorDescriptor(
        <ReduceTensorDescriptor>reduceTensorDesc)
    check_status(status)


cpdef size_t getReductionIndicesSize(size_t handle, size_t reduceTensorDesc,
                                     size_t aDesc, size_t cDesc) except? 0:
    cdef size_t sizeInBytes
    status = cudnnGetReductionIndicesSize(
        <Handle>handle, <ReduceTensorDescriptor>reduceTensorDesc,
        <TensorDescriptor>aDesc, <TensorDescriptor>cDesc, &sizeInBytes)
    check_status(status)
    return sizeInBytes


cpdef size_t getReductionWorkspaceSize(size_t handle, size_t reduceTensorDesc,
                                       size_t aDesc, size_t cDesc) except? 0:
    cdef size_t sizeInBytes
    status = cudnnGetReductionWorkspaceSize(
        <Handle>handle, <ReduceTensorDescriptor>reduceTensorDesc,
        <TensorDescriptor>aDesc, <TensorDescriptor>cDesc,
        &sizeInBytes)
    check_status(status)
    return sizeInBytes


cpdef reduceTensor(size_t handle, size_t reduceTensorDesc, size_t indices,
                   size_t indicesSizeInBytes, size_t workspace,
                   size_t workspaceSizeInBytes, size_t alpha, size_t aDesc,
                   size_t A, size_t beta, size_t cDesc, size_t C):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnReduceTensor(
            <Handle>handle, <ReduceTensorDescriptor>reduceTensorDesc,
            <void*>indices, indicesSizeInBytes, <void*>workspace,
            workspaceSizeInBytes, <void*>alpha, <TensorDescriptor>aDesc,
            <void*>A, <void*>beta, <TensorDescriptor>cDesc, <void*>C)
    check_status(status)


cpdef setTensor(size_t handle, size_t yDesc, size_t y, size_t valuePtr):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnSetTensor(
            <Handle>handle, <TensorDescriptor>yDesc, <void*>y,
            <void*>valuePtr)
    check_status(status)


cpdef scaleTensor(size_t handle, size_t yDesc, size_t y, size_t alpha):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnScaleTensor(
            <Handle>handle, <TensorDescriptor>yDesc, <void*> y,
            <void*>alpha)
    check_status(status)


###############################################################################
# Filter manipulation
###############################################################################

cpdef size_t createFilterDescriptor() except? 0:
    cdef FilterDescriptor desc
    status = cudnnCreateFilterDescriptor(&desc)
    check_status(status)
    return <size_t>desc


cpdef setFilter4dDescriptor_v4(
        size_t filterDesc, int dataType,
        int format, int k, int c, int h, int w):
    status = cudnnSetFilter4dDescriptor_v4(
        <FilterDescriptor>filterDesc, <DataType> dataType,
        <TensorFormat> format, k, c, h, w)
    check_status(status)


cpdef setFilterNdDescriptor_v4(
        size_t filterDesc, int dataType,
        int format, int nbDims, size_t filterDimA):
    status = cudnnSetFilterNdDescriptor_v4(
        <FilterDescriptor>filterDesc, <DataType>dataType,
        <TensorFormat>format, nbDims, <int*>filterDimA)
    check_status(status)


cpdef getFilterNdDescriptor(size_t wDesc, int nbDimsRequested):
    cdef DataType dataType
    cdef TensorFormat format
    cdef int nbDims
    cdef vector.vector[int] filterDimA
    filterDimA.resize(nbDimsRequested)

    status = cudnnGetFilterNdDescriptor_v4(
        <FilterDescriptor>wDesc, nbDimsRequested, &dataType,
        &format, &nbDims, &filterDimA[0])
    check_status(status)
    return dataType, format, nbDims, tuple(filterDimA)


cpdef destroyFilterDescriptor(size_t filterDesc):
    status = cudnnDestroyFilterDescriptor(<FilterDescriptor>filterDesc)
    check_status(status)


###############################################################################
# Convolution
###############################################################################

cpdef size_t createConvolutionDescriptor() except? 0:
    cdef ConvolutionDescriptor desc
    status = cudnnCreateConvolutionDescriptor(&desc)
    check_status(status)
    return <size_t>desc


cpdef setConvolutionMathType(size_t convDesc, size_t mathType):
    status = cudnnSetConvolutionMathType(
        <ConvolutionDescriptor>convDesc, <MathType>mathType)
    check_status(status)


cpdef size_t getConvolutionMathType(size_t convDesc) except? 0:
    cdef MathType mathType
    status = cudnnGetConvolutionMathType(
        <ConvolutionDescriptor>convDesc, &mathType)
    return <size_t>mathType


cpdef setConvolutionGroupCount(size_t convDesc, int groupCount):
    status = cudnnSetConvolutionGroupCount(
        <ConvolutionDescriptor>convDesc, groupCount)
    check_status(status)


cpdef int getConvolutionGroupCount(size_t convDesc) except? -1:
    cdef int groupCount
    status = cudnnGetConvolutionGroupCount(
        <ConvolutionDescriptor>convDesc, &groupCount)
    return groupCount


cpdef setConvolution2dDescriptor_v4(
        size_t convDesc, int pad_h, int pad_w, int u, int v, int dilation_h,
        int dilation_w, int mode):
    status = cudnnSetConvolution2dDescriptor_v4(
        <ConvolutionDescriptor>convDesc, pad_h, pad_w, u, v, dilation_h,
        dilation_w, <ConvolutionMode>mode)
    check_status(status)


cpdef setConvolution2dDescriptor_v5(
        size_t convDesc, int pad_h, int pad_w, int u, int v, int dilation_h,
        int dilation_w, int mode, size_t computeType):
    status = cudnnSetConvolution2dDescriptor_v5(
        <ConvolutionDescriptor>convDesc, pad_h, pad_w, u, v, dilation_h,
        dilation_w, <ConvolutionMode>mode, <DataType>computeType)
    check_status(status)


cpdef setConvolutionNdDescriptor_v3(
        size_t convDesc, int arrayLength, size_t padA, size_t filterStrideA,
        size_t dilationA, int mode, int dataType):
    status = cudnnSetConvolutionNdDescriptor_v3(
        <ConvolutionDescriptor>convDesc, arrayLength, <int*>padA,
        <int*>filterStrideA, <int*>dilationA, <ConvolutionMode>mode,
        <DataType>dataType)
    check_status(status)


cpdef destroyConvolutionDescriptor(size_t convDesc):
    status = cudnnDestroyConvolutionDescriptor(
        <ConvolutionDescriptor>convDesc)
    check_status(status)


cpdef findConvolutionForwardAlgorithm(
        size_t handle, size_t xDesc, size_t wDesc, size_t convDesc,
        size_t yDesc, int requestedAlgoCount):
    cdef vector.vector[ConvolutionFwdAlgoPerf] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnFindConvolutionForwardAlgorithm(
        <Handle> handle, <TensorDescriptor>xDesc, <FilterDescriptor>wDesc,
        <ConvolutionDescriptor>convDesc, <TensorDescriptor>yDesc,
        requestedAlgoCount, &returnedAlgoCount, &perfResults[0])
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return perfResults


cpdef list findConvolutionForwardAlgorithmEx(
        size_t handle, size_t xDesc, size_t x, size_t wDesc, size_t w,
        size_t convDesc, size_t yDesc, size_t y, int requestedAlgoCount,
        size_t workSpace, size_t workSpaceSizeInBytes):
    cdef vector.vector[ConvolutionFwdAlgoPerf] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnFindConvolutionForwardAlgorithmEx(
        <Handle> handle, <TensorDescriptor>xDesc, <void*>x,
        <FilterDescriptor>wDesc, <void*>w, <ConvolutionDescriptor>convDesc,
        <TensorDescriptor>yDesc, <void*>y, requestedAlgoCount,
        &returnedAlgoCount, &perfResults[0], <void*>workSpace,
        workSpaceSizeInBytes)
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return [CuDNNAlgoPerf(p.algo, p.status, p.time, p.memory, -1, -1)
            for p in perfResults]


cpdef list findConvolutionForwardAlgorithmEx_v7(
        size_t handle, size_t xDesc, size_t x, size_t wDesc, size_t w,
        size_t convDesc, size_t yDesc, size_t y, int requestedAlgoCount,
        size_t workSpace, size_t workSpaceSizeInBytes):
    cdef vector.vector[ConvolutionFwdAlgoPerf_v7] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnFindConvolutionForwardAlgorithmEx_v7(
        <Handle> handle, <TensorDescriptor>xDesc, <void*>x,
        <FilterDescriptor>wDesc, <void*>w, <ConvolutionDescriptor>convDesc,
        <TensorDescriptor>yDesc, <void*>y, requestedAlgoCount,
        &returnedAlgoCount, &perfResults[0], <void*>workSpace,
        workSpaceSizeInBytes)
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return [CuDNNAlgoPerf(p.algo, p.status, p.time, p.memory,
                          p.determinism, p.mathType)
            for p in perfResults]


cpdef int getConvolutionForwardAlgorithm_v6(
        size_t handle, size_t srcDesc, size_t filterDesc, size_t convDesc,
        size_t destDesc, int preference, size_t memoryLimitInbytes) except? -1:
    cdef ConvolutionFwdAlgo algo
    status = cudnnGetConvolutionForwardAlgorithm_v6(
        <Handle>handle, <TensorDescriptor>srcDesc,
        <FilterDescriptor>filterDesc, <ConvolutionDescriptor>convDesc,
        <TensorDescriptor>destDesc, <ConvolutionFwdPreference>preference,
        memoryLimitInbytes, &algo)
    check_status(status)
    return algo


cpdef list getConvolutionForwardAlgorithm_v7(
        size_t handle, size_t srcDesc, size_t filterDesc, size_t convDesc,
        size_t destDesc, int requestedAlgoCount):
    cdef vector.vector[ConvolutionFwdAlgoPerf_v7] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnGetConvolutionForwardAlgorithm_v7(
        <Handle> handle, <TensorDescriptor>srcDesc,
        <FilterDescriptor>filterDesc, <ConvolutionDescriptor>convDesc,
        <TensorDescriptor>destDesc, requestedAlgoCount,
        &returnedAlgoCount, &perfResults[0])
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return [CuDNNAlgoPerf(p.algo, p.status, p.time, p.memory,
                          p.determinism, p.mathType)
            for p in perfResults]


cpdef Py_ssize_t getConvolutionForwardWorkspaceSize(
        size_t handle, size_t srcDesc, size_t filterDesc, size_t convDesc,
        size_t destDesc, int algo) except? -1:
    cdef size_t sizeInBytes
    status = cudnnGetConvolutionForwardWorkspaceSize(
        <Handle>handle, <TensorDescriptor>srcDesc,
        <FilterDescriptor>filterDesc, <ConvolutionDescriptor> convDesc,
        <TensorDescriptor>destDesc, <ConvolutionFwdAlgo>algo, &sizeInBytes)
    check_status(status)
    return <Py_ssize_t>sizeInBytes


cpdef convolutionForward(
        size_t handle, size_t alpha, size_t srcDesc, size_t srcData,
        size_t filterDesc, size_t filterData, size_t convDesc, int algo,
        size_t workSpace, size_t workSpaceSizeInBytes, size_t beta,
        size_t destDesc, size_t destData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnConvolutionForward(
            <Handle>handle, <void*>alpha,
            <TensorDescriptor>srcDesc, <void*>srcData,
            <FilterDescriptor>filterDesc, <void*>filterData,
            <ConvolutionDescriptor>convDesc, <ConvolutionFwdAlgo>algo,
            <void*>workSpace, workSpaceSizeInBytes, <void*>beta,
            <TensorDescriptor>destDesc, <void*>destData)
    check_status(status)


cpdef convolutionBackwardBias(
        size_t handle, size_t alpha, size_t srcDesc, size_t srcData,
        size_t beta, size_t destDesc, size_t destData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnConvolutionBackwardBias(
            <Handle>handle, <void*>alpha,
            <TensorDescriptor>srcDesc, <void*>srcData, <void*>beta,
            <TensorDescriptor>destDesc, <void*>destData)
    check_status(status)


cpdef findConvolutionBackwardFilterAlgorithm(
        size_t handle, size_t xDesc, size_t dyDesc, size_t convDesc,
        size_t dwDesc, int requestedAlgoCount):
    cdef vector.vector[ConvolutionBwdFilterAlgoPerf] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnFindConvolutionBackwardFilterAlgorithm(
        <Handle> handle, <TensorDescriptor>xDesc, <TensorDescriptor>dyDesc,
        <ConvolutionDescriptor>convDesc, <FilterDescriptor>dwDesc,
        requestedAlgoCount, &returnedAlgoCount, &perfResults[0])
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return perfResults


cpdef list findConvolutionBackwardFilterAlgorithmEx(
        size_t handle, size_t xDesc, size_t x, size_t dyDesc, size_t dy,
        size_t convDesc, size_t dwDesc, size_t dw, int requestedAlgoCount,
        size_t workSpace, size_t workSpaceSizeInBytes):
    cdef vector.vector[ConvolutionBwdFilterAlgoPerf] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnFindConvolutionBackwardFilterAlgorithmEx(
        <Handle> handle, <TensorDescriptor>xDesc, <void*>x,
        <TensorDescriptor>dyDesc, <void*>dy, <ConvolutionDescriptor>convDesc,
        <FilterDescriptor>dwDesc, <void*>dw,
        requestedAlgoCount, &returnedAlgoCount, &perfResults[0],
        <void*>workSpace, workSpaceSizeInBytes)
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return [CuDNNAlgoPerf(p.algo, p.status, p.time, p.memory, -1, -1)
            for p in perfResults]


cpdef list findConvolutionBackwardFilterAlgorithmEx_v7(
        size_t handle, size_t xDesc, size_t x, size_t dyDesc, size_t dy,
        size_t convDesc, size_t dwDesc, size_t dw, int requestedAlgoCount,
        size_t workSpace, size_t workSpaceSizeInBytes):
    cdef vector.vector[ConvolutionBwdFilterAlgoPerf_v7] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnFindConvolutionBackwardFilterAlgorithmEx_v7(
        <Handle> handle, <TensorDescriptor>xDesc, <void*>x,
        <TensorDescriptor>dyDesc, <void*>dy, <ConvolutionDescriptor>convDesc,
        <FilterDescriptor>dwDesc, <void*>dw,
        requestedAlgoCount, &returnedAlgoCount, &perfResults[0],
        <void*>workSpace, workSpaceSizeInBytes)
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return [CuDNNAlgoPerf(p.algo, p.status, p.time, p.memory,
                          p.determinism, p.mathType)
            for p in perfResults]


cpdef int getConvolutionBackwardFilterAlgorithm_v6(
        size_t handle, size_t srcDesc, size_t diffDesc, size_t convDesc,
        size_t filterDesc, int preference,
        size_t memoryLimitInbytes) except? -1:
    cdef ConvolutionBwdFilterAlgo algo
    status = cudnnGetConvolutionBackwardFilterAlgorithm_v6(
        <Handle>handle, <TensorDescriptor>srcDesc,
        <TensorDescriptor>diffDesc, <ConvolutionDescriptor>convDesc,
        <FilterDescriptor>filterDesc,
        <ConvolutionBwdFilterPreference>preference,
        memoryLimitInbytes, &algo)
    check_status(status)
    return algo


cpdef list getConvolutionBackwardFilterAlgorithm_v7(
        size_t handle, size_t srcDesc, size_t diffDesc, size_t convDesc,
        size_t gradDesc, int requestedAlgoCount):
    cdef vector.vector[ConvolutionBwdFilterAlgoPerf_v7] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnGetConvolutionBackwardFilterAlgorithm_v7(
        <Handle>handle, <TensorDescriptor>srcDesc, <TensorDescriptor>diffDesc,
        <ConvolutionDescriptor>convDesc, <FilterDescriptor>gradDesc,
        requestedAlgoCount, &returnedAlgoCount, &perfResults[0])
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return [CuDNNAlgoPerf(p.algo, p.status, p.time, p.memory,
                          p.determinism, p.mathType)
            for p in perfResults]


cpdef Py_ssize_t getConvolutionBackwardFilterWorkspaceSize(
        size_t handle, size_t srcDesc, size_t diffDesc, size_t convDesc,
        size_t filterDesc, int algo) except? -1:
    cdef size_t sizeInBytes
    status = cudnnGetConvolutionBackwardFilterWorkspaceSize(
        <Handle>handle, <TensorDescriptor>srcDesc,
        <TensorDescriptor>diffDesc, <ConvolutionDescriptor> convDesc,
        <FilterDescriptor>filterDesc, <ConvolutionBwdFilterAlgo>algo,
        &sizeInBytes)
    check_status(status)
    return <Py_ssize_t>sizeInBytes


cpdef convolutionBackwardFilter_v3(
        size_t handle, size_t alpha, size_t srcDesc, size_t srcData,
        size_t diffDesc, size_t diffData, size_t convDesc, int algo,
        size_t workSpace, size_t workSpaceSizeInBytes, size_t beta,
        size_t gradDesc, size_t gradData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnConvolutionBackwardFilter_v3(
            <Handle>handle, <void*>alpha,
            <TensorDescriptor>srcDesc, <void*>srcData,
            <TensorDescriptor>diffDesc, <void*>diffData,
            <ConvolutionDescriptor>convDesc, <ConvolutionBwdFilterAlgo>algo,
            <void*>workSpace, workSpaceSizeInBytes, <void*>beta,
            <FilterDescriptor>gradDesc, <void*>gradData)
    check_status(status)


cpdef findConvolutionBackwardDataAlgorithm(
        size_t handle, size_t wDesc, size_t dyDesc, size_t convDesc,
        size_t dxDesc, int requestedAlgoCount):
    cdef vector.vector[ConvolutionBwdDataAlgoPerf] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnFindConvolutionBackwardDataAlgorithm(
        <Handle> handle, <FilterDescriptor>wDesc, <TensorDescriptor>dyDesc,
        <ConvolutionDescriptor>convDesc, <TensorDescriptor>dxDesc,
        requestedAlgoCount, &returnedAlgoCount, &perfResults[0])
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return perfResults


cpdef list findConvolutionBackwardDataAlgorithmEx(
        size_t handle, size_t wDesc, size_t w, size_t dyDesc, size_t dy,
        size_t convDesc, size_t dxDesc, size_t dx,
        int requestedAlgoCount, size_t workSpace, size_t workSpaceSizeInBytes):
    cdef vector.vector[ConvolutionBwdDataAlgoPerf] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnFindConvolutionBackwardDataAlgorithmEx(
        <Handle> handle, <FilterDescriptor>wDesc, <void*>w,
        <TensorDescriptor>dyDesc, <void*>dy, <ConvolutionDescriptor>convDesc,
        <TensorDescriptor>dxDesc, <void*>dx,
        requestedAlgoCount, &returnedAlgoCount, &perfResults[0],
        <void*>workSpace, workSpaceSizeInBytes)
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return [CuDNNAlgoPerf(p.algo, p.status, p.time, p.memory, -1, -1)
            for p in perfResults]


cpdef list findConvolutionBackwardDataAlgorithmEx_v7(
        size_t handle, size_t wDesc, size_t w, size_t dyDesc, size_t dy,
        size_t convDesc, size_t dxDesc, size_t dx,
        int requestedAlgoCount, size_t workSpace, size_t workSpaceSizeInBytes):
    cdef vector.vector[ConvolutionBwdDataAlgoPerf_v7] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnFindConvolutionBackwardDataAlgorithmEx_v7(
        <Handle> handle, <FilterDescriptor>wDesc, <void*>w,
        <TensorDescriptor>dyDesc, <void*>dy, <ConvolutionDescriptor>convDesc,
        <TensorDescriptor>dxDesc, <void*>dx,
        requestedAlgoCount, &returnedAlgoCount, &perfResults[0],
        <void*>workSpace, workSpaceSizeInBytes)
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return [CuDNNAlgoPerf(p.algo, p.status, p.time, p.memory,
                          p.determinism, p.mathType)
            for p in perfResults]


cpdef int getConvolutionBackwardDataAlgorithm_v6(
        size_t handle, size_t filterDesc, size_t diffDesc, size_t convDesc,
        size_t gradDesc, size_t preference,
        size_t memoryLimitInbytes) except? -1:
    cdef ConvolutionBwdDataAlgo algo
    status = cudnnGetConvolutionBackwardDataAlgorithm_v6(
        <Handle>handle, <FilterDescriptor>filterDesc,
        <TensorDescriptor>diffDesc, <ConvolutionDescriptor>convDesc,
        <TensorDescriptor>gradDesc, <ConvolutionBwdDataPreference>preference,
        memoryLimitInbytes, &algo)
    check_status(status)
    return algo


cpdef list getConvolutionBackwardDataAlgorithm_v7(
        size_t handle, size_t filterDesc, size_t diffDesc, size_t convDesc,
        size_t gradDesc, int requestedAlgoCount):
    cdef vector.vector[ConvolutionBwdDataAlgoPerf_v7] perfResults
    cdef int returnedAlgoCount
    perfResults.resize(requestedAlgoCount)
    status = cudnnGetConvolutionBackwardDataAlgorithm_v7(
        <Handle>handle, <FilterDescriptor>filterDesc,
        <TensorDescriptor>diffDesc, <ConvolutionDescriptor>convDesc,
        <TensorDescriptor>gradDesc, requestedAlgoCount,
        &returnedAlgoCount, &perfResults[0])
    check_status(status)
    perfResults.resize(returnedAlgoCount)
    return [CuDNNAlgoPerf(p.algo, p.status, p.time, p.memory,
                          p.determinism, p.mathType)
            for p in perfResults]


cpdef Py_ssize_t getConvolutionBackwardDataWorkspaceSize(
        size_t handle, size_t filterDesc, size_t diffDesc, size_t convDesc,
        size_t gradDesc, int algo) except? -1:
    cdef size_t sizeInBytes
    status = cudnnGetConvolutionBackwardDataWorkspaceSize(
        <Handle>handle, <FilterDescriptor>filterDesc,
        <TensorDescriptor>diffDesc,
        <ConvolutionDescriptor>convDesc, <TensorDescriptor>gradDesc,
        <ConvolutionBwdDataAlgo>algo, &sizeInBytes)
    check_status(status)
    return <Py_ssize_t>sizeInBytes


cpdef convolutionBackwardData_v3(
        size_t handle, size_t alpha, size_t filterDesc, size_t filterData,
        size_t diffDesc, size_t diffData, size_t convDesc, int algo,
        size_t workSpace, size_t workSpaceSizeInBytes, size_t beta,
        size_t gradDesc, size_t gradData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnConvolutionBackwardData_v3(
            <Handle>handle, <void*>alpha,
            <FilterDescriptor>filterDesc, <void*>filterData,
            <TensorDescriptor>diffDesc, <void*>diffData,
            <ConvolutionDescriptor>convDesc, <ConvolutionBwdDataAlgo>algo,
            <void*>workSpace, workSpaceSizeInBytes, <void*>beta,
            <TensorDescriptor>gradDesc, <void*>gradData)
    check_status(status)

###############################################################################
# Pooling
###############################################################################

cpdef size_t createPoolingDescriptor() except? 0:
    cdef PoolingDescriptor desc
    status = cudnnCreatePoolingDescriptor(&desc)
    check_status(status)
    return <size_t>desc


cpdef setPooling2dDescriptor_v4(
        size_t poolingDesc, int mode, int maxpoolingNanOpt, int windowHeight,
        int windowWidth, int verticalPadding, int horizontalPadding,
        int verticalStride, int horizontalStride):
    status = cudnnSetPooling2dDescriptor_v4(
        <PoolingDescriptor>poolingDesc, <PoolingMode>mode,
        <NanPropagation>maxpoolingNanOpt, windowHeight, windowWidth,
        verticalPadding, horizontalPadding, verticalStride, horizontalStride)
    check_status(status)


cpdef setPoolingNdDescriptor_v4(
        size_t poolingDesc, int mode, int maxpoolingNanOpt, int nbDims,
        size_t windowDimA, size_t paddingA, size_t strideA):
    status = cudnnSetPoolingNdDescriptor_v4(
        <PoolingDescriptor>poolingDesc, <PoolingMode>mode,
        <NanPropagation>maxpoolingNanOpt, nbDims,
        <int*>windowDimA, <int*>paddingA, <int*>strideA)
    check_status(status)


cpdef destroyPoolingDescriptor(size_t poolingDesc):
    status = cudnnDestroyPoolingDescriptor(<PoolingDescriptor>poolingDesc)
    check_status(status)


cpdef poolingForward(
        size_t handle, size_t poolingDesc, size_t alpha, size_t srcDesc,
        size_t srcData, size_t beta, size_t dstDesc, size_t dstData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnPoolingForward(
            <Handle>handle, <PoolingDescriptor>poolingDesc, <void*>alpha,
            <TensorDescriptor>srcDesc, <void*>srcData, <void*>beta,
            <TensorDescriptor>dstDesc, <void*>dstData)
    check_status(status)


cpdef poolingBackward(
        size_t handle, size_t poolingDesc, size_t alpha, size_t srcDesc,
        size_t srcData, size_t srcDiffDesc, size_t srcDiffData,
        size_t destDesc, size_t destData, size_t beta, size_t destDiffDesc,
        size_t destDiffData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnPoolingBackward(
            <Handle>handle, <PoolingDescriptor>poolingDesc, <void*>alpha,
            <TensorDescriptor>srcDesc, <void*>srcData,
            <TensorDescriptor>srcDiffDesc, <void*>srcDiffData,
            <TensorDescriptor>destDesc, <void*>destData, <void*>beta,
            <TensorDescriptor>destDiffDesc, <void*>destDiffData)
    check_status(status)

###############################################################################
# Batch Normalization
###############################################################################

CUDNN_BN_MIN_EPSILON = _CUDNN_BN_MIN_EPSILON

cpdef deriveBNTensorDescriptor(
        size_t derivedBnDesc, size_t xDesc, int mode):
    status = cudnnDeriveBNTensorDescriptor(
        <TensorDescriptor>derivedBnDesc, <TensorDescriptor>xDesc,
        <BatchNormMode> mode)
    check_status(status)


cpdef batchNormalizationForwardTraining(
        size_t handle, int mode,
        size_t alpha, size_t beta, size_t xDesc,
        size_t x, size_t yDesc, size_t y,
        size_t bnScaleBiasMeanVarDesc, size_t bnScale,
        size_t bnBias, double exponentialAverageFactor,
        size_t resultRunningMean, size_t resultRunningVariance,
        double epsilon, size_t resultSaveMean, size_t resultSaveInvVariance):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnBatchNormalizationForwardTraining(
            <Handle>handle, <BatchNormMode> mode,
            <void*>alpha, <void*>beta, <TensorDescriptor>xDesc,
            <void*>x, <TensorDescriptor>yDesc, <void*>y,
            <TensorDescriptor>bnScaleBiasMeanVarDesc, <void*>bnScale,
            <void*>bnBias, exponentialAverageFactor,
            <void*>resultRunningMean, <void*>resultRunningVariance,
            epsilon, <void*>resultSaveMean, <void*>resultSaveInvVariance)
    check_status(status)


cpdef batchNormalizationForwardInference(
        size_t handle, int mode,
        size_t alpha, size_t beta, size_t xDesc,
        size_t x, size_t yDesc, size_t y,
        size_t bnScaleBiasMeanVarDesc, size_t bnScale,
        size_t bnBias, size_t estimatedMean, size_t estimatedVariance,
        double epsilon):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnBatchNormalizationForwardInference(
            <Handle>handle, <BatchNormMode> mode,
            <void*>alpha, <void*>beta, <TensorDescriptor>xDesc,
            <void*>x, <TensorDescriptor>yDesc, <void*>y,
            <TensorDescriptor>bnScaleBiasMeanVarDesc, <void*>bnScale,
            <void*>bnBias, <void*>estimatedMean, <void*>estimatedVariance,
            epsilon)
    check_status(status)


cpdef batchNormalizationBackward(
        size_t handle, int mode,
        size_t alphaDataDiff, size_t betaDataDiff,
        size_t alphaParamDiff, size_t betaParamDiff,
        size_t xDesc, size_t x, size_t dyDesc,
        size_t dy, size_t dxDesc, size_t dx,
        size_t dBnScaleBiasDesc, size_t bnScale,
        size_t dBnScaleResult, size_t dBnBiasResult,
        double epsilon, size_t savedMean, size_t savedInvVariance):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnBatchNormalizationBackward(
            <Handle>handle, <BatchNormMode>mode,
            <void*>alphaDataDiff, <void*>betaDataDiff,
            <void*>alphaParamDiff, <void*>betaParamDiff,
            <TensorDescriptor>xDesc, <void*>x,
            <TensorDescriptor>dyDesc, <void*>dy,
            <TensorDescriptor>dxDesc, <void*>dx,
            <TensorDescriptor>dBnScaleBiasDesc, <void*>bnScale,
            <void*>dBnScaleResult, <void*>dBnBiasResult,
            epsilon, <void*>savedMean, <void*>savedInvVariance)
    check_status(status)


cpdef batchNormalizationForwardTrainingEx(
        size_t handle, int mode, int bnOps,
        size_t alpha, size_t beta,
        size_t xDesc, size_t x,
        size_t zDesc, size_t z,
        size_t yDesc, size_t y,
        size_t bnScaleBiasMeanVarDesc,
        size_t bnScale, size_t bnBias,
        double exponentialAverageFactor,
        size_t resultRunningMean, size_t resultRunningVariance,
        double epsilon, size_t resultSaveMean, size_t resultSaveInvVariance,
        size_t activationDesc,
        size_t workSpace, size_t workSpaceSizeInBytes,
        size_t reserveSpace, size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnBatchNormalizationForwardTrainingEx(
            <Handle>handle, <BatchNormMode> mode, <BatchNormOps> bnOps,
            <void*>alpha, <void*>beta,
            <TensorDescriptor>xDesc, <void*>x,
            <TensorDescriptor>zDesc, <void*>z,
            <TensorDescriptor>yDesc, <void*>y,
            <TensorDescriptor>bnScaleBiasMeanVarDesc,
            <void*>bnScale, <void*>bnBias,
            exponentialAverageFactor,
            <void*>resultRunningMean, <void*>resultRunningVariance,
            epsilon, <void*>resultSaveMean, <void*>resultSaveInvVariance,
            <ActivationDescriptor>activationDesc,
            <void*>workSpace, workSpaceSizeInBytes,
            <void*>reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


cpdef size_t getBatchNormalizationForwardTrainingExWorkspaceSize(
        size_t handle, int mode, int bnOps,
        size_t xDesc,
        size_t zDesc,
        size_t yDesc,
        size_t bnScaleBiasMeanVarDesc,
        size_t activationDesc) except? 0:
    cdef size_t sizeInBytes
    status = cudnnGetBatchNormalizationForwardTrainingExWorkspaceSize(
        <Handle> handle,
        <BatchNormMode> mode, <BatchNormOps> bnOps,
        <TensorDescriptor> xDesc,
        <TensorDescriptor> zDesc,
        <TensorDescriptor> yDesc,
        <TensorDescriptor> bnScaleBiasMeanVarDesc,
        <ActivationDescriptor> activationDesc,
        &sizeInBytes)
    check_status(status)
    return sizeInBytes


cpdef batchNormalizationBackwardEx(
        size_t handle, int mode, int bnops,
        size_t alphaDataDiff, size_t betaDataDiff,
        size_t alphaParamDiff, size_t betaParamDiff,
        size_t xDesc, size_t x,
        size_t yDesc, size_t y,
        size_t dyDesc, size_t dy,
        size_t dzDesc, size_t dz,
        size_t dxDesc, size_t dx,
        size_t dBnScaleBiasDesc,
        size_t bnScaleData, size_t bnBiasData,
        size_t dBnScaleData, size_t dBnBiasData,
        double epsilon,
        size_t savedMean, size_t savedInvVariance,
        size_t activationDesc,
        size_t workSpace, size_t workSpaceSizeInBytes,
        size_t reserveSpace, size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnBatchNormalizationBackwardEx(
            <Handle> handle,
            <BatchNormMode> mode, <BatchNormOps> bnops,
            <void*> alphaDataDiff, <void*> betaDataDiff,
            <void*> alphaParamDiff, <void*> betaParamDiff,
            <TensorDescriptor> xDesc, <void*> x,
            <TensorDescriptor> yDesc, <void*> y,
            <TensorDescriptor> dyDesc, <void*> dy,
            <TensorDescriptor> dzDesc, <void*> dz,
            <TensorDescriptor> dxDesc, <void*> dx,
            <TensorDescriptor> dBnScaleBiasDesc,
            <void*> bnScaleData, <void*> bnBiasData,
            <void*> dBnScaleData, <void*> dBnBiasData,
            epsilon,
            <void*> savedMean, <void*> savedInvVariance,
            <ActivationDescriptor> activationDesc,
            <void*> workSpace, workSpaceSizeInBytes,
            <void*> reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


cpdef size_t getBatchNormalizationBackwardExWorkspaceSize(
        size_t handle, int mode, int bnOps,
        size_t xDesc,
        size_t yDesc,
        size_t dyDesc,
        size_t dzDesc,
        size_t dxDesc,
        size_t dBnScaleBiasDesc,
        size_t activationDesc) except? 0:
    cdef size_t sizeInBytes
    status = cudnnGetBatchNormalizationBackwardExWorkspaceSize(
        <Handle> handle,
        <BatchNormMode> mode,
        <BatchNormOps> bnOps,
        <TensorDescriptor> xDesc,
        <TensorDescriptor> yDesc,
        <TensorDescriptor> dyDesc,
        <TensorDescriptor> dzDesc,
        <TensorDescriptor> dxDesc,
        <TensorDescriptor> dBnScaleBiasDesc,
        <ActivationDescriptor> activationDesc,
        &sizeInBytes)
    check_status(status)
    return sizeInBytes


cpdef size_t getBatchNormalizationTrainingExReserveSpaceSize(
        size_t handle, int mode, int bnOps,
        size_t activationDesc,
        size_t xDesc) except? 0:
    cdef size_t sizeInBytes
    status = cudnnGetBatchNormalizationTrainingExReserveSpaceSize(
        <Handle> handle,
        <BatchNormMode> mode,
        <BatchNormOps> bnOps,
        <ActivationDescriptor> activationDesc,
        <TensorDescriptor> xDesc,
        &sizeInBytes)
    check_status(status)
    return sizeInBytes


###############################################################################
# Activation
###############################################################################

cpdef size_t createActivationDescriptor() except? 0:
    cdef ActivationDescriptor activationDesc
    status = cudnnCreateActivationDescriptor(&activationDesc)
    check_status(status)
    return <size_t>activationDesc


cpdef setActivationDescriptor(
        size_t activationDesc, int mode, int reluNanOpt, double reluCeiling):
    status = cudnnSetActivationDescriptor(
        <ActivationDescriptor>activationDesc, <ActivationMode>mode,
        <NanPropagation>reluNanOpt, reluCeiling)
    check_status(status)


cpdef destroyActivationDescriptor(size_t activationDesc):
    status = cudnnDestroyActivationDescriptor(
        <ActivationDescriptor>activationDesc)
    check_status(status)


cpdef softmaxForward(
        size_t handle, int algorithm, int mode, size_t alpha, size_t srcDesc,
        size_t srcData, size_t beta, size_t dstDesc, size_t dstData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnSoftmaxForward(
            <Handle>handle, <SoftmaxAlgorithm>algorithm, <SoftmaxMode>mode,
            <void*>alpha, <TensorDescriptor>srcDesc, <void*>srcData,
            <void*>beta, <TensorDescriptor>dstDesc, <void*>dstData)
    check_status(status)


cpdef softmaxBackward(
        size_t handle, int algorithm, int mode, size_t alpha, size_t srcDesc,
        size_t srcData, size_t srcDiffDesc, size_t srcDiffData, size_t beta,
        size_t destDiffDesc, size_t destDiffData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnSoftmaxBackward(
            <Handle>handle, <SoftmaxAlgorithm>algorithm, <SoftmaxMode>mode,
            <void*>alpha, <TensorDescriptor>srcDesc, <void*>srcData,
            <TensorDescriptor>srcDiffDesc, <void*>srcDiffData, <void*>beta,
            <TensorDescriptor>destDiffDesc, <void*>destDiffData)
    check_status(status)


cpdef activationForward_v4(
        size_t handle, size_t activationDesc, size_t alpha, size_t srcDesc,
        size_t srcData, size_t beta, size_t dstDesc, size_t dstData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnActivationForward_v4(
            <Handle>handle, <ActivationDescriptor>activationDesc, <void*>alpha,
            <TensorDescriptor>srcDesc, <void*>srcData, <void*>beta,
            <TensorDescriptor>dstDesc, <void*>dstData)
    check_status(status)


cpdef activationBackward_v4(
        size_t handle, size_t activationDesc, size_t alpha, size_t srcDesc,
        size_t srcData, size_t srcDiffDesc, size_t srcDiffData,
        size_t destDesc, size_t destData, size_t beta, size_t destDiffDesc,
        size_t destDiffData):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnActivationBackward_v4(
            <Handle>handle, <ActivationDescriptor>activationDesc, <void*>alpha,
            <TensorDescriptor>srcDesc, <void*>srcData,
            <TensorDescriptor>srcDiffDesc, <void*>srcDiffData,
            <TensorDescriptor>destDesc, <void*>destData, <void*>beta,
            <TensorDescriptor>destDiffDesc, <void*>destDiffData)
    check_status(status)


###############################################################################
# Dropout
###############################################################################

cpdef size_t createDropoutDescriptor() except? 0:
    cdef DropoutDescriptor desc
    status = cudnnCreateDropoutDescriptor(&desc)
    check_status(status)
    return <size_t>desc


cpdef destroyDropoutDescriptor(size_t dropoutDesc):
    status = cudnnDestroyDropoutDescriptor(<DropoutDescriptor>dropoutDesc)
    check_status(status)


cpdef Py_ssize_t dropoutGetStatesSize(size_t handle) except? -1:
    cdef size_t sizeInBytes
    status = cudnnDropoutGetStatesSize(
        <Handle>handle, &sizeInBytes)
    check_status(status)
    return <Py_ssize_t>sizeInBytes


cpdef setDropoutDescriptor(
        size_t dropoutDesc, size_t handle, float dropout,
        size_t states, size_t stateSizeInBytes, unsigned long long seed):
    status = cudnnSetDropoutDescriptor(
        <DropoutDescriptor>dropoutDesc, <Handle>handle, dropout,
        <void*>states, stateSizeInBytes, seed)
    check_status(status)


cpdef size_t getDropoutReserveSpaceSize(size_t xDesc) except? 0:
    cdef size_t sizeInBytes
    status = cudnnDropoutGetReserveSpaceSize(
        <TensorDescriptor>xDesc, &sizeInBytes)
    check_status(status)
    return sizeInBytes


cpdef dropoutForward(
        size_t handle, size_t dropoutDesc,
        size_t srcDesc, size_t srcData,
        size_t dstDesc, size_t dstData,
        size_t reserveSpace, size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnDropoutForward(
            <Handle>handle, <DropoutDescriptor>dropoutDesc,
            <TensorDescriptor>srcDesc, <void*>srcData,
            <TensorDescriptor>dstDesc, <void*>dstData,
            <void*>reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


cpdef dropoutBackward(
        size_t handle, size_t dropoutDesc,
        size_t dyDesc, size_t dyData,
        size_t dxDesc, size_t dxData,
        size_t reserveSpace, size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnDropoutBackward(
            <Handle>handle, <DropoutDescriptor>dropoutDesc,
            <TensorDescriptor>dyDesc, <void*>dyData,
            <TensorDescriptor>dxDesc, <void*>dxData,
            <void*>reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


###############################################################################
# CTC
###############################################################################
cpdef size_t createCTCLossDescriptor() except? 0:
    cdef CTCLossDescriptor desc
    status = cudnnCreateCTCLossDescriptor(&desc)
    check_status(status)
    return <size_t>desc

cpdef destroyCTCLossDescriptor(size_t ctcLossDesc):
    status = cudnnDestroyCTCLossDescriptor(<CTCLossDescriptor>ctcLossDesc)
    check_status(status)

cpdef setCTCLossDescriptor(size_t ctcLossDesc, int dataType):
    status = cudnnSetCTCLossDescriptor(
        <CTCLossDescriptor>ctcLossDesc, <DataType>dataType)
    check_status(status)

cpdef getCTCLossDescriptor(size_t ctcLossDesc):
    cdef DataType compType
    status = cudnnGetCTCLossDescriptor(
        <CTCLossDescriptor>ctcLossDesc, &compType)
    check_status(status)
    return compType

cpdef size_t getCTCLossWorkspaceSize(
        size_t handle, size_t probsDesc, size_t gradientsDesc,
        size_t labels, size_t labelLengths, size_t inputLengths,
        int algo, size_t ctcLossDesc) except? 0:
    cdef size_t sizeInBytes
    status = cudnnGetCTCLossWorkspaceSize(
        <Handle>handle, <TensorDescriptor>probsDesc,
        <TensorDescriptor>gradientsDesc,
        <int*>labels, <int*>labelLengths, <int*>inputLengths,
        <CTCLossAlgo>algo, <CTCLossDescriptor>ctcLossDesc, &sizeInBytes)
    check_status(status)
    return sizeInBytes

cpdef CTCLoss(
        size_t handle, size_t probsDesc,
        size_t probs, size_t labels, size_t labelLengths, size_t inputLengths,
        size_t costs, size_t gradientsDesc, size_t gradients,
        int algo, size_t ctcLossDesc,
        size_t workspace, size_t workSpaceSizeInBytes):
    status = cudnnCTCLoss(
        <Handle>handle, <TensorDescriptor>probsDesc, <void*>probs,
        <int*>labels, <int*>labelLengths, <int*>inputLengths,
        <void*>costs, <TensorDescriptor>gradientsDesc, <void*>gradients,
        <CTCLossAlgo>algo, <CTCLossDescriptor>ctcLossDesc,
        <void*>workspace, <size_t>workSpaceSizeInBytes)
    check_status(status)


###############################################################################
# RNN
###############################################################################

cpdef size_t createRNNDescriptor() except? 0:
    cdef RNNDescriptor desc
    status = cudnnCreateRNNDescriptor(&desc)
    check_status(status)
    return <size_t>desc


cpdef destroyRNNDescriptor(size_t rnnDesc):
    status = cudnnDestroyRNNDescriptor(<RNNDescriptor>rnnDesc)
    check_status(status)


cpdef size_t createPersistentRNNPlan(size_t rnnDesc, int minibatch,
                                     int dataType) except? 0:
    cdef PersistentRNNPlan plan
    status = cudnnCreatePersistentRNNPlan(
        <RNNDescriptor>rnnDesc,
        <int>minibatch, <DataType>dataType, &plan)
    check_status(status)
    return <size_t>plan


cpdef setPersistentRNNPlan(size_t rnnDesc, size_t plan):
    status = cudnnSetPersistentRNNPlan(
        <RNNDescriptor>rnnDesc, <PersistentRNNPlan>plan)
    check_status(status)


cpdef destroyPersistentRNNPlan(size_t plan):
    status = cudnnDestroyPersistentRNNPlan(<PersistentRNNPlan>plan)
    check_status(status)


cpdef setRNNDescriptor_v5(
        size_t rnnDesc, int hiddenSize, int numLayers,
        size_t dropoutDesc, int inputMode, int direction, int mode,
        int dataType):
    status = cudnnSetRNNDescriptor_v5(
        <RNNDescriptor>rnnDesc, hiddenSize, numLayers,
        <DropoutDescriptor>dropoutDesc, <RNNInputMode>inputMode,
        <DirectionMode>direction, <RNNMode>mode, <DataType>dataType)
    check_status(status)


cpdef setRNNDescriptor_v6(
        size_t handle, size_t rnnDesc, int hiddenSize, int numLayers,
        size_t dropoutDesc, int inputMode, int direction, int mode,
        int algo, int dataType):
    status = cudnnSetRNNDescriptor_v6(
        <Handle>handle, <RNNDescriptor>rnnDesc, hiddenSize, numLayers,
        <DropoutDescriptor>dropoutDesc, <RNNInputMode>inputMode,
        <DirectionMode>direction, <RNNMode>mode, <RNNAlgo>algo,
        <DataType>dataType)
    check_status(status)


cpdef setRNNPaddingMode(
        size_t rnnDesc, int paddingMode):
    status = cudnnSetRNNPaddingMode(
        <RNNDescriptor>rnnDesc, <RNNPaddingMode>paddingMode)
    check_status(status)


cpdef getRNNPaddingMode(size_t rnnDesc):
    cdef RNNPaddingMode paddingMode
    status = cudnnGetRNNPaddingMode(
        <RNNDescriptor>rnnDesc, &paddingMode)
    check_status(status)
    return paddingMode


cpdef size_t createRNNDataDescriptor() except? 0:
    cdef RNNDataDescriptor desc
    status = cudnnCreateRNNDataDescriptor(&desc)
    check_status(status)
    return <size_t>desc


cpdef destroyRNNDataDescriptor(size_t RNNDataDesc):
    status = cudnnDestroyRNNDataDescriptor(<RNNDataDescriptor>RNNDataDesc)
    check_status(status)


cpdef setRNNDataDescriptor(
        size_t RNNDataDesc, int dataType, size_t layout,
        int maxSeqLength, int batchSize, int vectorSize,
        size_t seqLengthArray, size_t paddingFill):
    status = cudnnSetRNNDataDescriptor(
        <RNNDataDescriptor>RNNDataDesc, <DataType>dataType,
        <RNNDataLayout>layout, maxSeqLength, batchSize, vectorSize,
        <const int*>seqLengthArray, <void*>paddingFill)
    check_status(status)


cpdef getRNNDataDescriptor(
        size_t RNNDataDesc, size_t dataType,
        size_t layout, size_t maxSeqLength, size_t batchSize,
        size_t vectorSize, int arrayLengthRequested, size_t seqLengthArray,
        size_t paddingFill):
    status = cudnnGetRNNDataDescriptor(
        <RNNDataDescriptor>RNNDataDesc, <DataType*>dataType,
        <RNNDataLayout*>layout, <int*>maxSeqLength, <int*>batchSize,
        <int*>vectorSize, arrayLengthRequested, <int*>seqLengthArray,
        <void*>paddingFill)
    check_status(status)


cpdef getRNNWorkspaceSize(
        size_t handle, size_t rnnDesc, int seqLength, size_t xDesc):
    cdef size_t sizeInBytes
    status = cudnnGetRNNWorkspaceSize(
        <Handle>handle, <RNNDescriptor>rnnDesc, seqLength,
        <TensorDescriptor*>xDesc, &sizeInBytes)
    check_status(status)
    return sizeInBytes


cpdef getRNNTrainingReserveSize(
        size_t handle, size_t rnnDesc, int seqLength, size_t xDesc):
    cdef size_t sizeInBytes
    status = cudnnGetRNNTrainingReserveSize(
        <Handle>handle, <RNNDescriptor>rnnDesc, seqLength,
        <TensorDescriptor*>xDesc, &sizeInBytes)
    check_status(status)
    return sizeInBytes


cpdef getRNNParamsSize(
        size_t handle, size_t rnnDesc, size_t xDesc, int dataType):
    cdef size_t sizeInBytes
    status = cudnnGetRNNParamsSize(
        <Handle>handle, <RNNDescriptor>rnnDesc, <TensorDescriptor>xDesc,
        &sizeInBytes, <DataType>dataType)
    check_status(status)
    return sizeInBytes


cpdef getRNNLinLayerMatrixParams(
        size_t handle, size_t rnnDesc, int layer, size_t xDesc, size_t wDesc,
        size_t w, int linLayerID, size_t linLayerMatDesc, size_t linLayerMat):
    status = cudnnGetRNNLinLayerMatrixParams(
        <Handle>handle, <RNNDescriptor>rnnDesc, layer,
        <TensorDescriptor>xDesc, <FilterDescriptor>wDesc, <void*>w,
        linLayerID, <FilterDescriptor>linLayerMatDesc, <void**>linLayerMat)
    check_status(status)


cpdef getRNNLinLayerBiasParams(
        size_t handle, size_t rnnDesc, int layer, size_t xDesc, size_t wDesc,
        size_t w, int linLayerID, size_t linLayerBiasDesc,
        size_t linLayerBias):
    status = cudnnGetRNNLinLayerBiasParams(
        <Handle>handle, <RNNDescriptor>rnnDesc, layer,
        <TensorDescriptor>xDesc, <FilterDescriptor>wDesc, <void*>w,
        linLayerID, <FilterDescriptor>linLayerBiasDesc, <void**>linLayerBias)
    check_status(status)


cpdef RNNForwardInference(
        size_t handle, size_t rnnDesc, int seqLength, size_t xDesc,
        size_t x, size_t hxDesc, size_t hx, size_t cxDesc,
        size_t cx, size_t wDesc, size_t w, size_t yDesc,
        size_t y, size_t hyDesc, size_t hy, size_t cyDesc,
        size_t cy, size_t workspace, size_t workSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnRNNForwardInference(
            <Handle>handle, <RNNDescriptor>rnnDesc, seqLength,
            <TensorDescriptor*>xDesc, <void*>x,
            <TensorDescriptor>hxDesc, <void*>hx,
            <TensorDescriptor>cxDesc, <void*>cx,
            <FilterDescriptor>wDesc, <void*>w,
            <TensorDescriptor*>yDesc, <void*>y,
            <TensorDescriptor>hyDesc, <void*>hy,
            <TensorDescriptor>cyDesc, <void*>cy,
            <void*>workspace, workSpaceSizeInBytes)
    check_status(status)


cpdef RNNForwardTraining(
        size_t handle, size_t rnnDesc, int seqLength, size_t xDesc, size_t x,
        size_t hxDesc, size_t hx, size_t cxDesc, size_t cx,
        size_t wDesc, size_t w, size_t yDesc, size_t y,
        size_t hyDesc, size_t hy, size_t cyDesc, size_t cy,
        size_t workspace, size_t workSpaceSizeInBytes, size_t reserveSpace,
        size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnRNNForwardTraining(
            <Handle>handle, <RNNDescriptor>rnnDesc, seqLength,
            <TensorDescriptor*>xDesc, <void*>x,
            <TensorDescriptor>hxDesc, <void*>hx,
            <TensorDescriptor>cxDesc, <void*>cx,
            <FilterDescriptor>wDesc, <void*>w,
            <TensorDescriptor*>yDesc, <void*>y,
            <TensorDescriptor>hyDesc, <void*> hy,
            <TensorDescriptor>cyDesc, <void*>cy,
            <void*>workspace, workSpaceSizeInBytes,
            <void*>reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


cpdef RNNBackwardData(
        size_t handle, size_t rnnDesc, int seqLength, size_t yDesc, size_t y,
        size_t dyDesc, size_t dy, size_t dhyDesc, size_t dhy,
        size_t dcyDesc, size_t dcy, size_t wDesc, size_t w,
        size_t hxDesc, size_t hx, size_t cxDesc, size_t cx,
        size_t dxDesc, size_t dx, size_t dhxDesc, size_t dhx,
        size_t dcxDesc, size_t dcx, size_t workspace,
        size_t workSpaceSizeInBytes, size_t reserveSpace,
        size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnRNNBackwardData(
            <Handle>handle, <RNNDescriptor>rnnDesc, seqLength,
            <TensorDescriptor*>yDesc, <void*>y,
            <TensorDescriptor*>dyDesc, <void*>dy,
            <TensorDescriptor>dhyDesc, <void*>dhy,
            <TensorDescriptor>dcyDesc, <void*>dcy,
            <FilterDescriptor>wDesc, <void*>w,
            <TensorDescriptor>hxDesc, <void*>hx,
            <TensorDescriptor>cxDesc, <void*>cx,
            <TensorDescriptor*>dxDesc, <void*>dx,
            <TensorDescriptor>dhxDesc, <void*>dhx,
            <TensorDescriptor>dcxDesc, <void*>dcx,
            <void*>workspace, workSpaceSizeInBytes,
            <void*>reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


cpdef RNNBackwardWeights(
        size_t handle, size_t rnnDesc, int seqLength, size_t xDesc, size_t x,
        size_t hxDesc, size_t hx, size_t yDesc, size_t y,
        size_t workspace, size_t workSpaceSizeInBytes, size_t dwDesc,
        size_t dw, size_t reserveSpace, size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnRNNBackwardWeights(
            <Handle>handle, <RNNDescriptor>rnnDesc, seqLength,
            <TensorDescriptor*>xDesc, <void*>x,
            <TensorDescriptor>hxDesc, <void*>hx,
            <TensorDescriptor*>yDesc, <void*>y,
            <void*>workspace, workSpaceSizeInBytes,
            <FilterDescriptor>dwDesc, <void*>dw,
            <void*>reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


cpdef RNNForwardInferenceEx(
        size_t handle, size_t rnnDesc, size_t xDesc, size_t x, size_t hxDesc,
        size_t hx, size_t cxDesc, size_t cx, size_t wDesc, size_t w,
        size_t yDesc, size_t y, size_t hyDesc, size_t hy, size_t cyDesc,
        size_t cy, size_t kDesc, size_t keys, size_t cDesc, size_t cAttn,
        size_t iDesc, size_t iAttn, size_t qDesc, size_t queries,
        size_t workSpace, size_t workSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnRNNForwardInferenceEx(
            <Handle>handle, <RNNDescriptor>rnnDesc,
            <RNNDataDescriptor>xDesc, <const void*>x,
            <TensorDescriptor>hxDesc, <const void*>hx,
            <TensorDescriptor>cxDesc, <const void*>cx,
            <FilterDescriptor>wDesc, <const void*>w,
            <RNNDataDescriptor>yDesc, <void*>y,
            <TensorDescriptor>hyDesc, <void*>hy,
            <TensorDescriptor>cyDesc, <void*>cy,
            <RNNDataDescriptor>kDesc, <const void*>keys,
            <RNNDataDescriptor>cDesc, <void*>cAttn,
            <RNNDataDescriptor>iDesc, <void*>iAttn,
            <RNNDataDescriptor>qDesc, <void*>queries,
            <void*>workSpace, workSpaceSizeInBytes)
    check_status(status)


cpdef RNNForwardTrainingEx(
        size_t handle, size_t rnnDesc, size_t xDesc, size_t x, size_t hxDesc,
        size_t hx, size_t cxDesc, size_t cx, size_t wDesc, size_t w,
        size_t yDesc, size_t y, size_t hyDesc, size_t hy, size_t cyDesc,
        size_t cy, size_t kDesc, size_t keys, size_t cDesc, size_t cAttn,
        size_t iDesc, size_t iAttn, size_t qDesc, size_t queries,
        size_t workSpace, size_t workSpaceSizeInBytes,
        size_t reserveSpace, size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnRNNForwardTrainingEx(
            <Handle>handle, <RNNDescriptor>rnnDesc,
            <RNNDataDescriptor>xDesc, <const void*>x,
            <TensorDescriptor>hxDesc, <const void*>hx,
            <TensorDescriptor>cxDesc, <const void*>cx,
            <FilterDescriptor>wDesc, <const void*>w,
            <RNNDataDescriptor>yDesc, <void*>y,
            <TensorDescriptor>hyDesc, <void*>hy,
            <TensorDescriptor>cyDesc, <void*>cy,
            <RNNDataDescriptor>kDesc, <const void*>keys,
            <RNNDataDescriptor>cDesc, <void*>cAttn,
            <RNNDataDescriptor>iDesc, <void*>iAttn,
            <RNNDataDescriptor>qDesc, <void*>queries,
            <void*>workSpace, workSpaceSizeInBytes,
            <void*>reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


cpdef RNNBackwardDataEx(
        size_t handle, size_t rnnDesc, size_t yDesc, size_t y, size_t dyDesc,
        size_t dy, size_t dcDesc, size_t dcAttn, size_t dhyDesc, size_t dhy,
        size_t dcyDesc, size_t dcy, size_t wDesc, size_t w, size_t hxDesc,
        size_t hx, size_t cxDesc, size_t cx, size_t dxDesc, size_t dx,
        size_t dhxDesc, size_t dhx, size_t dcxDesc, size_t dcx,
        size_t dkDesc, size_t dkeys,
        size_t workSpace, size_t workSpaceSizeInBytes,
        size_t reserveSpace, size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnRNNBackwardDataEx(
            <Handle>handle, <RNNDescriptor>rnnDesc,
            <RNNDataDescriptor>yDesc, <const void*>y,
            <RNNDataDescriptor>dyDesc, <const void*>dy,
            <RNNDataDescriptor>dcDesc, <const void*>dcAttn,
            <TensorDescriptor>dhyDesc, <const void*>dhy,
            <TensorDescriptor>dcyDesc, <const void*>dcy,
            <FilterDescriptor>wDesc, <const void*>w,
            <TensorDescriptor>hxDesc, <const void*>hx,
            <TensorDescriptor>cxDesc, <const void*>cx,
            <RNNDataDescriptor>dxDesc, <void*>dx,
            <TensorDescriptor>dhxDesc, <void*>dhx,
            <TensorDescriptor>dcxDesc, <void*>dcx,
            <RNNDataDescriptor>dkDesc, <void*>dkeys,
            <void*>workSpace, workSpaceSizeInBytes,
            <void*>reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


cpdef RNNBackwardWeightsEx(
        size_t handle, size_t rnnDesc, size_t xDesc, size_t x,
        size_t hxDesc, size_t hx, size_t yDesc, size_t y,
        size_t workSpace, size_t workSpaceSizeInBytes,
        size_t dwDesc, size_t dw,
        size_t reserveSpace, size_t reserveSpaceSizeInBytes):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnRNNBackwardWeightsEx(
            <Handle>handle, <RNNDescriptor>rnnDesc,
            <RNNDataDescriptor>xDesc, <const void*>x,
            <TensorDescriptor>hxDesc, <const void*>hx,
            <RNNDataDescriptor>yDesc, <const void*>y,
            <void*>workSpace, workSpaceSizeInBytes,
            <FilterDescriptor>dwDesc, <void*>dw,
            <void*>reserveSpace, reserveSpaceSizeInBytes)
    check_status(status)


###############################################################################
# Spatial Transformer
###############################################################################

cpdef size_t createSpatialTransformerDescriptor() except? 0:
    cdef SpatialTransformerDescriptor stDesc
    status = cudnnCreateSpatialTransformerDescriptor(&stDesc)
    check_status(status)
    return <size_t>stDesc


cpdef destroySpatialTransformerDescriptor(size_t stDesc):
    status = cudnnDestroySpatialTransformerDescriptor(
        <SpatialTransformerDescriptor>stDesc)
    check_status(status)


cpdef setSpatialTransformerDescriptor(
        size_t stDesc, size_t samplerType, int dataType,
        int nbDims, size_t dimA):
    status = cudnnSetSpatialTransformerNdDescriptor(
        <SpatialTransformerDescriptor>stDesc, <SamplerType>samplerType,
        <DataType>dataType, nbDims, <int*>dimA)
    check_status(status)


cpdef spatialTfGridGeneratorForward(
        size_t handle, size_t stDesc, size_t theta, size_t grid):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnSpatialTfGridGeneratorForward(
            <Handle>handle, <SpatialTransformerDescriptor> stDesc,
            <void*>theta, <void*>grid)
    check_status(status)


cpdef spatialTfGridGeneratorBackward(
        size_t handle, size_t stDesc, size_t dgrid, size_t dtheta):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnSpatialTfGridGeneratorBackward(
            <Handle>handle, <SpatialTransformerDescriptor>stDesc,
            <void*>dgrid, <void*>dtheta)
    check_status(status)


cpdef spatialTfSamplerForward(
        size_t handle, size_t stDesc, size_t alpha, size_t xDesc,
        size_t x, size_t grid, size_t beta, size_t yDesc, size_t y):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnSpatialTfSamplerForward(
            <Handle>handle, <SpatialTransformerDescriptor>stDesc,
            <void*>alpha, <TensorDescriptor>xDesc, <void*>x, <void*>grid,
            <void*>beta, <TensorDescriptor>yDesc, <void*>y)
    check_status(status)


cpdef spatialTfSamplerBackward(
        size_t handle, size_t stDesc, size_t alpha, size_t xDesc,
        size_t x, size_t beta, size_t dxDesc, size_t dx, size_t alphaDgrid,
        size_t dyDesc, size_t dy, size_t grid, size_t betaDgrid, size_t dgrid):
    setStream(handle, stream_module.get_current_stream_ptr())
    with nogil:
        status = cudnnSpatialTfSamplerBackward(
            <Handle>handle, <SpatialTransformerDescriptor>stDesc,
            <void*>alpha, <TensorDescriptor>xDesc, <void*>x, <void*>beta,
            <TensorDescriptor>dxDesc, <void*>dx, <void*>alphaDgrid,
            <TensorDescriptor>dyDesc, <void*>dy, <void*>grid,
            <void*>betaDgrid, <void*>dgrid)
    check_status(status)


###############################################################################
# Multi-head attention
###############################################################################

cpdef size_t createAttnDescriptor():
    cdef AttnDescriptor attnDesc
    status = cudnnCreateAttnDescriptor(&attnDesc)
    check_status(status)
    return <size_t>attnDesc


cpdef destroyAttnDescriptor(size_t attnDesc):
    status = cudnnDestroyAttnDescriptor(<AttnDescriptor>attnDesc)
    check_status(status)


cpdef getAttnDescriptor(
    size_t attnDesc, size_t queryMap,
    size_t nHeads, size_t smScaler, size_t dataType,
    size_t computePrec, size_t mathType,
    size_t attnDropoutDesc,
    size_t postDropoutDesc,
    size_t qSize, size_t kSize, size_t vSize, size_t qProjSize,
    size_t kProjSize, size_t vProjSize, size_t oProjSize,
    size_t qoMaxSeqLength, size_t kvMaxSeqLength,
    size_t maxBatchSize, size_t maxBeamSize):
    status = cudnnGetAttnDescriptor(
        <AttnDescriptor>attnDesc, <AttnQueryMap*>queryMap,
        <int*>nHeads, <double*>smScaler, <DataType*>dataType,
        <DataType*>computePrec, <MathType*>mathType,
        <DropoutDescriptor*>attnDropoutDesc,
        <DropoutDescriptor*>postDropoutDesc,
        <int*>qSize, <int*>kSize, <int*>vSize, <int*>qProjSize,
        <int*>kProjSize, <int*>vProjSize, <int*>oProjSize,
        <int*>qoMaxSeqLength, <int*>kvMaxSeqLength,
        <int*>maxBatchSize, <int*>maxBeamSize)
    check_status(status)


cpdef getMultiHeadAttnBuffers(
    size_t handle, size_t attnDesc,
    size_t weightSizeInBytes, size_t workSpaceSizeInBytes,
    size_t reserveSpaceSizeInBytes):
    status = cudnnGetMultiHeadAttnBuffers(
        <Handle>handle, <AttnDescriptor>attnDesc,
        <size_t*>weightSizeInBytes, <size_t*>workSpaceSizeInBytes,
        <size_t*>reserveSpaceSizeInBytes)
    check_status(status)


cpdef getMultiHeadAttnWeights(
    size_t handle, size_t attnDesc,
    int wKind, size_t weightSizeInBytes,
    size_t w, size_t wDesc,
    size_t wAddr):
    status = cudnnGetMultiHeadAttnWeights(
        <Handle>handle, <AttnDescriptor>attnDesc,
        <MultiHeadAttnWeightKind>wKind, weightSizeInBytes,
        <const void*>w, <TensorDescriptor>wDesc,
        <void**>wAddr)
    check_status(status)


cpdef multiHeadAttnBackwardData(
    size_t handle, size_t attnDesc,
    size_t loWinIdx, size_t hiWinIdx,
    size_t seqLengthArrayDQDO, size_t seqLengthArrayDKDV,
    size_t doDesc, size_t dout,
    size_t dqDesc, size_t dqueries,
    size_t queries, size_t dkDesc,
    size_t dkeys, size_t keys,
    size_t dvDesc, size_t dvalues,
    size_t values, size_t weightSizeInBytes,
    size_t w, size_t workSpaceSizeInBytes,
    size_t workSpace, size_t reserveSpaceSizeInBytes,
    size_t reserveSpace):
    status = cudnnMultiHeadAttnBackwardData(
        <Handle>handle, <const AttnDescriptor>attnDesc,
        <const int*>loWinIdx, <const int*> hiWinIdx,
        <const int*>seqLengthArrayDQDO, <const int*>seqLengthArrayDKDV,
        <const SeqDataDescriptor>doDesc, <const void*> dout,
        <const SeqDataDescriptor>dqDesc, <void*> dqueries,
        <const void*>queries, <const SeqDataDescriptor>dkDesc,
        <void*>dkeys, <const void*>keys,
        <const SeqDataDescriptor>dvDesc, <void*>dvalues,
        <const void*>values, weightSizeInBytes,
        <const void*>w, workSpaceSizeInBytes,
        <void*>workSpace, reserveSpaceSizeInBytes,
        <void*>reserveSpace)
    check_status(status)


cpdef multiHeadAttnBackwardWeights(
    size_t handle, size_t attnDesc,
    int addGrad, size_t qDesc,
    size_t queries, size_t kDesc,
    size_t keys, size_t vDesc,
    size_t values, size_t doDesc,
    size_t dout, size_t weightSizeInBytes,
    size_t w, size_t dw,
    size_t workSpaceSizeInBytes, size_t workSpace,
    size_t reserveSpaceSizeInBytes, size_t reserveSpace):
    status = cudnnMultiHeadAttnBackwardWeights(
        <Handle>handle, <AttnDescriptor> attnDesc,
        <WgradMode>addGrad, <SeqDataDescriptor>qDesc,
        <const void*>queries, <SeqDataDescriptor>kDesc,
        <const void*>keys, <SeqDataDescriptor>vDesc,
        <const void*>values, <SeqDataDescriptor>doDesc,
        <const void*>dout, weightSizeInBytes,
        <const void*>w, <void*>dw,
        workSpaceSizeInBytes, <void*>workSpace,
        reserveSpaceSizeInBytes, <void*>reserveSpace)
    check_status(status)


cpdef multiHeadAttnForward(
    size_t handle, size_t attnDesc,
    int currIdx, size_t loWinIdx,
    size_t hiWinIdx, size_t seqLengthArrayQRO,
    size_t seqLengthArrayKV, size_t qDesc,
    size_t queries, size_t residuals,
    size_t kDesc, size_t keys,
    size_t vDesc, size_t values,
    size_t oDesc, size_t out,
    size_t weightSizeInBytes, size_t w,
    size_t workSpaceSizeInBytes, size_t workSpace,
    size_t reserveSpaceSizeInBytes, size_t reserveSpace):
    status = cudnnMultiHeadAttnForward(
        <Handle>handle, <AttnDescriptor>attnDesc,
        currIdx, <const int*>loWinIdx,
        <const int*>hiWinIdx, <const int*>seqLengthArrayQRO,
        <const int*>seqLengthArrayKV, <SeqDataDescriptor>qDesc,
        <const void*>queries, <const void*>residuals,
        <SeqDataDescriptor> kDesc, <const void*>keys,
        <SeqDataDescriptor> vDesc, <const void*>values,
        <SeqDataDescriptor> oDesc, <void*>out,
        weightSizeInBytes, <const void*>w,
        workSpaceSizeInBytes, <void*>workSpace,
        reserveSpaceSizeInBytes, <void*>reserveSpace)
    check_status(status)


cpdef setAttnDescriptor(
    size_t attnDesc, int queryMap,
    int nHeads, double smScaler,
    int dataType, int computePrec,
    int mathType, size_t attnDropoutDesc,
    size_t postDropoutDesc,
    int qSize, int kSize, int vSize, int qProjSize,
    int kProjSize, int vProjSize, int oProjSize,
    int qoMaxSeqLength, int kvMaxSeqLength,
    int maxBatchSize, int maxBeamSize):
    status = cudnnSetAttnDescriptor(
        <AttnDescriptor>attnDesc, <AttnQueryMap>queryMap,
        nHeads, smScaler,
        <DataType>dataType, <DataType>computePrec,
        <MathType>mathType, <DropoutDescriptor>attnDropoutDesc,
        <DropoutDescriptor>postDropoutDesc,
        qSize, kSize, vSize, qProjSize,
        kProjSize, vProjSize, oProjSize,
        qoMaxSeqLength, kvMaxSeqLength,
        maxBatchSize, maxBeamSize)


cpdef createSeqDataDescriptor():
    cdef SeqDataDescriptor seqDataDesc
    status = cudnnCreateSeqDataDescriptor(&seqDataDesc)
    check_status(status)
    return <size_t>seqDataDesc


cpdef destroySeqDataDescriptor(size_t seqDataDesc):
    status = cudnnDestroySeqDataDescriptor(<SeqDataDescriptor>seqDataDesc)
    check_status(status)


cpdef getSeqDataDescriptor(
    size_t seqDataDesc, size_t dataType,
    size_t nbDims, int nbDimsRequested,
    size_t dimA, size_t axes,
    size_t seqLengthArraySize, size_t seqLengthSizeRequsted,
    size_t seqLengthArray, size_t paddingFill):
    status = cudnnGetSeqDataDescriptor(
        <SeqDataDescriptor>seqDataDesc,
        <DataType*> dataType,
        <int*> nbDims,
        nbDimsRequested,
        <int*>dimA,
        <SeqDataAxis*>axes,
        <size_t*>seqLengthArraySize,
        seqLengthSizeRequsted,
        <int*>seqLengthArray,
        <void*>paddingFill)
    check_status(status)


cpdef setSeqDataDescriptor(
    size_t seqDataDesc, int dataType,
    int nbDims, size_t dimA,
    size_t axes, size_t seqLengthArraySize,
    size_t seqLengthArray, size_t paddingFill):
    status = cudnnSetSeqDataDescriptor(
        <SeqDataDescriptor>seqDataDesc,
        <DataType>dataType,
        nbDims,
        <const int*>dimA,
        <const SeqDataAxis*> axes,
        seqLengthArraySize,
        <const int*>seqLengthArray,
        <void*>paddingFill)
    check_status(status)
