export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'quickSort' : IDL.Func([IDL.Vec(IDL.Int)], [IDL.Vec(IDL.Int)], []),
  });
};
export const init = ({ IDL }) => { return []; };
