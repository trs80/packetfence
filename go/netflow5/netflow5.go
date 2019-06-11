package netflow5

type NetFlow5 struct {
    Header Header
	Flows [30]Flow
}

type Handler func(header *Header, i int, flow *Flow)
