function a = parenDelete(a,indexOp)
% PARENDELETE   Customize handling of object index deletions
%
%   See also PARENDELETE
%
%   written ... 2024-02-23 ... UCHINO Yuki

arguments (Input)
    a DD
    indexOp (1,1) matlab.indexing.IndexingOperation
end

a.v1(indexOp.Indices{:}) = [];
a.v2(indexOp.Indices{:}) = [];
end