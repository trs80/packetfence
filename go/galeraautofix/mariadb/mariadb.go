package mariadb

import (
	"context"
	"fmt"
	"net"
	"os/exec"
	"regexp"
	"strconv"
	"strings"

	"github.com/inverse-inc/packetfence/go/log"
)

const RunningSeqno = -1
const DefaultSeqno = -2

func ForceStop(ctx context.Context) error {
	err := exec.Command(`systemctl`, `stop`, `packetfence-mariadb`).Run()
	if err != nil {
		log.LoggerWContext(ctx).Error("Failed to stop the MariaDB service via systemctl: " + err.Error())
		return err
	}

	exec.Command(`pkill`, `-9`, `-f`, `mysqld`).Run()

	return nil
}

func ClearAndStart(ctx context.Context) error {
	err := exec.Command(`rm`, `-fr`, `/var/lib/mysql/*`).Run()
	if err != nil {
		log.LoggerWContext(ctx).Error("Failed to empty the /var/lib/mysql/ directory: " + err.Error())
		return err
	}

	err = exec.Command(`systemctl`, `start`, `packetfence-mariadb`).Run()
	if err != nil {
		log.LoggerWContext(ctx).Error("Failed to start packetfence-mariadb: " + err.Error())
		return err
	}

	return nil
}

func StartNewCluster(ctx context.Context) error {

	err := exec.Command(`systemctl`, `set-environment`, `MARIADB_ARGS=--force-new-cluster`).Run()
	if err != nil {
		log.LoggerWContext(ctx).Error("Failed to set the MARIADB_ARGS environment variable in systemctl" + err.Error())
		return err
	}

	err = exec.Command(`systemctl`, `start`, `packetfence-mariadb.service`).Run()
	if err != nil {
		log.LoggerWContext(ctx).Error("Failed to start packetfence-mariadb in force new cluster mode: " + err.Error())
		return err
	}

	err = exec.Command(`systemctl`, `unset-environment`, `MARIADB_ARGS`).Run()
	if err != nil {
		log.LoggerWContext(ctx).Error("Failed to unset the MARIADB_ARGS environment variable in systemctl" + err.Error())
		return err
	}

	return nil
}

func WsrepRecover(ctx context.Context) error {
	err := exec.Command(`mysqld_safe`, `--defaults-file=/usr/local/pf/var/conf/mariadb.conf`, `--wsrep-recover`).Run()
	if err != nil {
		log.LoggerWContext(ctx).Error("Unable to perform wsrep-recover: " + err.Error())
		return err
	}

	return nil
}

func GetSeqno(ctx context.Context) (int, error) {
	cmd := exec.Command(`bash`, `-c`, `grep seqno: /var/lib/mysql/grastate.dat | grep -oP '\-?[0-9]+'`)
	out, err := cmd.Output()
	if err != nil {
		log.LoggerWContext(ctx).Error("Unable to obtain sequence number (seqno) from /var/lib/mysql/grastate.dat: " + err.Error())
		return DefaultSeqno, err
	}
	outStr := strings.TrimSuffix(string(out), "\n")
	intResult, err := strconv.Atoi(outStr)
	if err != nil {
		log.LoggerWContext(ctx).Error(fmt.Sprintf("Unable to parse sequence number '%s' from /var/lib/mysql/grastate.dat: %s", outStr, err.Error()))
		return DefaultSeqno, err
	}

	return intResult, nil
}

func IsLocalDBAvailable(ctx context.Context) bool {
	conn, err := net.Dial("unix", "/var/lib/mysql/mysql.sock")
	if err != nil {
		log.LoggerWContext(ctx).Warn(fmt.Sprintf("The database on this node is not available right now: %s", err.Error()))
		return false
	} else {
		buf := make([]byte, 1024)
		len, err := conn.Read(buf[:])
		conn.Close()
		if err != nil || len == 0 {
			log.LoggerWContext(ctx).Warn("The database on this node is not available right now: unable to read from established connection")
			return false
		}
		return true
	}
}

func IsActive(ctx context.Context) bool {
	cmd := exec.Command(`systemctl`, `is-active`, `packetfence-mariadb`)
	out, _ := cmd.Output()
	outStr := strings.TrimSuffix(string(out), "\n")
	if matched, _ := regexp.MatchString(`^activ`, outStr); matched {
		log.LoggerWContext(ctx).Info("packetfence-mariadb is currently in a state considered active on this node: " + outStr)
		return true
	} else {
		log.LoggerWContext(ctx).Info("packetfence-mariadb is currently in a state considered inactive on this node: " + outStr)
		return false
	}
}
