package aaa

import (
	"testing"
	"time"

	"github.com/davecgh/go-spew/spew"
)

func TestTokenBackend(t *testing.T) {
	for _, test := range []struct {
		name string
		b    TokenBackend
	}{
		{"MemTokenBackend", NewMemTokenBackend(1*time.Second, 1*time.Second, []string{})},
		{"RedisTokenBackend", NewRedisTokenBackend(1*time.Second, 1*time.Second, []string{})},
		{"DbTokenBackend", NewDbTokenBackend(1*time.Second, 1*time.Second, []string{})},
		{"MultiTokenBackend BlackHole+MemTokenBackend", NewMultiTokenBackend(NewBlackhole(), NewMemTokenBackend(1*time.Second, 1*time.Second, []string{}))},
	} {
		b := test.b
		t.Run(test.name, func(t *testing.T) {
			token := "my-beautiful-token"

			if b.TokenIsValid(token) {
				t.Error("Non existing token is invalid")
			}

			roles := b.AdminActionsForToken(token)

			if len(roles) != 0 {
				t.Error("Got some roles for an existant token", spew.Sdump(roles))
			}

			b.StoreTokenInfo(token, &TokenInfo{
				AdminRoles: map[string]bool{
					"Node Manager": true,
				},
			})

			if !b.TokenIsValid(token) {
				t.Error("Existing token is not valid")
			}

			roles = b.AdminActionsForToken(token)

			if len(roles) != 4 {
				t.Error("Got the wrong amount of roles for an existant token", spew.Sdump(roles))
			}

			// Test the expiration
			time.Sleep(1 * time.Second)

			if b.TokenIsValid(token) {
				t.Error("Non existing token is invalid")
			}

			roles = b.AdminActionsForToken(token)

			if len(roles) != 0 {
				t.Error("Got some roles for an expired token", spew.Sdump(roles))
			}
		},
		)
	}

}

type Blackhole struct {
}

func NewBlackhole() TokenBackend {
	return &Blackhole{}
}

func (tb *Blackhole) TokenInfoForToken(token string) (*TokenInfo, time.Time) {
	return nil, time.Unix(0, 0)
}

func (tb *Blackhole) StoreTokenInfo(token string, ti *TokenInfo) error {
	return nil
}

func (tb *Blackhole) TokenIsValid(token string) bool {
	return false
}

func (tb *Blackhole) TouchTokenInfo(token string) {
}

func (tb *Blackhole) AdminActionsForToken(token string) map[string]bool {
	return nil
}

var _ TokenBackend = (*Blackhole)(nil)
