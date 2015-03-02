function writeAnisotropicVistaMesh(meshfile)
	m = load(meshfile); % loads [vert, elem, label, tensors]
	write_vista_mesh([meshfile 'HeadModel.v'],m.vert, m.elem, double(m.label), m.tensors);
end
