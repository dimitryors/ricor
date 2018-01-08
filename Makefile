BASEDIR = $(shell pwd)
REBAR = rebar3
RELPATH = _build/default/rel/ricor
PRODRELPATH = _build/prod/rel/ricor
APPNAME = ricor
SHELL = /bin/bash

release:
	$(REBAR) release
	mkdir -p $(RELPATH)/../ricor_config
	[ -f $(RELPATH)/../ricor_config/ricor.conf ] || cp $(RELPATH)/etc/ricor.conf  $(RELPATH)/../ricor_config/ricor.conf
	[ -f $(RELPATH)/../ricor_config/advanced.config ] || cp $(RELPATH)/etc/advanced.config  $(RELPATH)/../ricor_config/advanced.config

console:
	cd $(RELPATH) && ./bin/ricor console

prod-release:
	$(REBAR) as prod release
	mkdir -p $(PRODRELPATH)/../ricor_config
	[ -f $(PRODRELPATH)/../ricor_config/ricor.conf ] || cp $(PRODRELPATH)/etc/ricor.conf  $(PRODRELPATH)/../ricor_config/ricor.conf
	[ -f $(PRODRELPATH)/../ricor_config/advanced.config ] || cp $(PRODRELPATH)/etc/advanced.config  $(PRODRELPATH)/../ricor_config/advanced.config

prod-console:
	cd $(PRODRELPATH) && ./bin/ricor console

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean

test:
	$(REBAR) ct

devrel1:
	$(REBAR) as dev1 release

devrel2:
	$(REBAR) as dev2 release

devrel3:
	$(REBAR) as dev3 release

devrel: devrel1 devrel2 devrel3

dev1-console:
	$(BASEDIR)/_build/dev1/rel/ricor/bin/$(APPNAME) console

dev2-console:
	$(BASEDIR)/_build/dev2/rel/ricor/bin/$(APPNAME) console

dev3-console:
	$(BASEDIR)/_build/dev3/rel/ricor/bin/$(APPNAME) console

devrel-start:
	for d in $(BASEDIR)/_build/dev*; do $$d/rel/ricor/bin/$(APPNAME) start; done

devrel-join:
	for d in $(BASEDIR)/_build/dev{2,3}; do $$d/rel/ricor/bin/$(APPNAME)-admin cluster join ricor1@127.0.0.1; done

devrel-cluster-plan:
	$(BASEDIR)/_build/dev1/rel/ricor/bin/$(APPNAME)-admin cluster plan

devrel-cluster-commit:
	$(BASEDIR)/_build/dev1/rel/ricor/bin/$(APPNAME)-admin cluster commit

devrel-status:
	$(BASEDIR)/_build/dev1/rel/ricor/bin/$(APPNAME)-admin member-status

devrel-ping:
	for d in $(BASEDIR)/_build/dev*; do $$d/rel/ricor/bin/$(APPNAME) ping; done

devrel-stop:
	for d in $(BASEDIR)/_build/dev*; do $$d/rel/ricor/bin/$(APPNAME) stop; done

start:
	$(BASEDIR)/$(RELPATH)/bin/$(APPNAME) start

stop:
	$(BASEDIR)/$(RELPATH)/bin/$(APPNAME) stop

attach:
	$(BASEDIR)/$(RELPATH)/bin/$(APPNAME) attach

