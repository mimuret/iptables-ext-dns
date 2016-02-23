#include "autoconfig.h"
#include "kernel.h"
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/ctype.h>
#include <linux/module.h>
#include <linux/ip.h>
#include <net/ipv6.h>
#include <net/tcp.h>
#include <net/udp.h>
#include <linux/netfilter/x_tables.h>
#include <linux/netfilter_ipv6/ip6_tables.h>
#include "xt_dns.h"
#include "xt_dns_header.h"

MODULE_AUTHOR("Manabu Sonoda <mimuret@gmail.com>");
MODULE_DESCRIPTION("Xtables: DNS matching");
MODULE_LICENSE("GPL");

MODULE_ALIAS("ipt_dns");
MODULE_ALIAS("ip6t_dns");

#ifdef DEBUG
#define DEBUG_PRINT(fmt, ...)                                                  \
    {                                                                          \
        printk(KERN_DEBUG "xt_dns %s(%d):" fmt "\n", __func__, __LINE__,       \
               ##__VA_ARGS__);                                                 \
    }
#else
#define DEBUG_PRINT(...)
#endif

#if KERNEL_VERSION >= 3
#define XT_PARAM struct xt_action_param
#define HOTDROP(par) par->hotdrop = true
#else
#define XT_PARAM const struct xt_match_param
#define HOTDROP(par) *par->hotdrop = true
#endif

static bool dns_mt(const struct sk_buff *skb, XT_PARAM *par, int16_t offset) {
    const struct dns_h *dh; // dns header working pointer
    struct dns_h _dnsh;     // dns header buffer

    uint16_t qlen; // qname length, MAX 255
    uint16_t mlen; // match qname length, MAX 255
    uint8_t llen;  // label length, MAX 63

    uint8_t *qname;                 // qname working pointer
    uint8_t _qname[XT_DNS_MAXSIZE]; // qname buffer
    uint16_t qtype;                 // qtype buffer

    const struct xt_dns *dnsinfo = par->matchinfo;

    DEBUG_PRINT("start dns match");

    //	offset += par->thoff;
    dh = skb_header_pointer(skb, offset, sizeof(_dnsh), &_dnsh);
    DEBUG_PRINT("get dns header?");

    if (dh == NULL) {
        DEBUG_PRINT("xt_dns: invalid dns header");
        HOTDROP(par);
        return false;
    }
    DEBUG_PRINT("success get dns header");
    offset += sizeof(_dnsh);

#define FWINVDNS(bool, invflag) ((bool)^(dnsinfo->invflags & invflag))

    if (dnsinfo->qr && !FWINVDNS(dh->qr, XT_DNS_FLAG_QR)) {
        DEBUG_PRINT("not match qr flag");
        return false;
    }
    if ((dnsinfo->setflags & XT_DNS_FLAG_OPCODE) &&
        !FWINVDNS((dh->opcode == dnsinfo->opcode), XT_DNS_FLAG_OPCODE)) {
        DEBUG_PRINT("not match OPCODE");
        return false;
    }
    if (dnsinfo->aa && !FWINVDNS(dh->aa, XT_DNS_FLAG_AA)) {
        DEBUG_PRINT("not match aa flag");
        return false;
    }
    if (dnsinfo->tc && !FWINVDNS(dh->tc, XT_DNS_FLAG_TC)) {
        DEBUG_PRINT("not match tc flag");
        return false;
    }
    if (dnsinfo->rd && !FWINVDNS(dh->rd, XT_DNS_FLAG_RD)) {
        DEBUG_PRINT("not match rd flag");
        return false;
    }
    if (dnsinfo->ra && !FWINVDNS(dh->ra, XT_DNS_FLAG_RA)) {
        DEBUG_PRINT("not match ra flag");
        return false;
    }
    if (dnsinfo->ad && !FWINVDNS(dh->ad, XT_DNS_FLAG_AD)) {
        DEBUG_PRINT("not match ad flag");
        return false;
    }
    if (dnsinfo->cd && !FWINVDNS(dh->cd, XT_DNS_FLAG_CD)) {
        DEBUG_PRINT("not match cd flag");
        return false;
    }
    if ((dnsinfo->setflags & XT_DNS_FLAG_RCODE) &&
        !FWINVDNS((dh->rcode == dnsinfo->rcode), XT_DNS_FLAG_RCODE)) {
        DEBUG_PRINT("not match RCODE");
        return false;
    }
    DEBUG_PRINT("xt_dns: bit check done");
    if ((dnsinfo->setflags & XT_DNS_FLAG_QNAME) ||
        (dnsinfo->setflags & XT_DNS_FLAG_QTYPE)) {
        DEBUG_PRINT("xt_dns: start parse qname");
        qname = _qname;
        qlen = 0;
        llen = 255;
        while (llen != 0 && qlen < XT_DNS_MAXSIZE) {
            // read label size
            if (skb_copy_bits(skb, offset, &llen, sizeof(uint8_t)) < 0 ||
                llen > XT_DNS_LABEL_MAXSIZE) {
                DEBUG_PRINT("xt_dns: invalid label len.");
                HOTDROP(par);
                return false;
            }
            if (qlen + llen + 1 <= XT_DNS_MAXSIZE &&
                skb_copy_bits(skb, offset, (qname + qlen),
                              sizeof(uint8_t) * (llen + 1)) < 0) {
                DEBUG_PRINT("xt_dns: invalid label name %u,%u", qlen, llen);
                HOTDROP(par);
                return false;
            }
            qlen += llen + 1;
            offset += llen + 1;
        }
        DEBUG_PRINT("xt_dns: success qname parse. ");
        if (!FWINVDNS((qlen <= dnsinfo->maxsize), XT_DNS_FLAG_QNAME_MAXSIZE)) {
            DEBUG_PRINT("qname longer than maxsize %d > %d", qlen,
                        dnsinfo->maxsize);
            return false;
        }
        if (skb_copy_bits(skb, offset, &qtype, sizeof(qtype)) < 0) {
            DEBUG_PRINT("xt_dns: invalid qtype");
            HOTDROP(par);
            return false;
        }
        if ((dnsinfo->setflags & XT_DNS_FLAG_QTYPE) &&
            !FWINVDNS((qtype == dnsinfo->qtype), XT_DNS_FLAG_QTYPE)) {
            DEBUG_PRINT("not match qtype");
            return false;
        }
        if (dnsinfo->setflags & XT_DNS_FLAG_QNAME) {
            qlen = mlen = 0;
            DEBUG_PRINT("start qname matching.");
            while (qlen < XT_DNS_MAXSIZE && qname[qlen] != 0 &&
                   dnsinfo->qname[mlen] != 0) {
                if (tolower(qname[qlen++]) != dnsinfo->qname[mlen++]) {
                    if (dnsinfo->rmatch) {
                        mlen = 0;
                    } else {
                        break;
                    }
                }
            }
            if (!FWINVDNS((qname[qlen] == 0 && dnsinfo->qname[mlen] == 0),
                          XT_DNS_FLAG_QNAME)) {
                DEBUG_PRINT("not match qname");
                return false;
            }
        }
    }
    DEBUG_PRINT("match success");
    return true;
}
static bool dns_mt_tcp(const struct sk_buff *skb, XT_PARAM *par,
                       int16_t offset) {
    const struct tcphdr *th;
    struct tcphdr _tcph;

    DEBUG_PRINT("packet is TCP");

    th = skb_header_pointer(skb, offset, sizeof(_tcph), &_tcph);

    if (th == NULL) {
        DEBUG_PRINT("xt_dns: invalid tcp header.");
        HOTDROP(par);
        return false;
    }
    if (!(th->ack & th->psh) ||
        (ntohs(th->source) != DNS_PORT && ntohs(th->dest) != DNS_PORT)) {
        DEBUG_PRINT("not dns packet");
        return false;
    }

    return dns_mt(skb, par, offset + th->doff * 4 + 2);
}
static bool dns_mt_udp(const struct sk_buff *skb, XT_PARAM *par,
                       int16_t offset) {
    const struct udphdr *uh;
    struct udphdr _udph;

    DEBUG_PRINT("packet is UDP");

    uh = skb_header_pointer(skb, offset, sizeof(_udph), &_udph);

    if (uh == NULL) {
        DEBUG_PRINT("xt_dns: invalid udp header.");
        HOTDROP(par);
        return false;
    }
    if (ntohs(uh->source) != DNS_PORT && ntohs(uh->dest) != DNS_PORT) {
        DEBUG_PRINT("not dns packet");
        return false;
    }

    return dns_mt(skb, par, offset + sizeof(_udph));
}
static bool dns_mt4(const struct sk_buff *skb, XT_PARAM *par) {
    struct iphdr _iph;
    const struct iphdr *ih;
    DEBUG_PRINT("start ipv4");
    if (par->fragoff != 0) {
        DEBUG_PRINT("fragment packet");
        return false;
    }
    ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
    if (ih->protocol == IPPROTO_UDP) {
        return dns_mt_udp(skb, par, sizeof(_iph));
    }
    if (ih->protocol == IPPROTO_TCP) {
        return dns_mt_tcp(skb, par, sizeof(_iph));
    }
    DEBUG_PRINT("unsupported protocol.");
    return false;
}

static bool dns_mt6(const struct sk_buff *skb, XT_PARAM *par) {
    struct ipv6hdr _iph;
    const struct ipv6hdr *ih;
    int16_t ptr;

    struct ipv6_opt_hdr _hdr;
    const struct ipv6_opt_hdr *hp;

    uint8_t currenthdr;
    uint16_t hdrlen = 0;

    if (par->fragoff != 0) {
        DEBUG_PRINT("fragment packet");
        return false;
    }

    DEBUG_PRINT("start ipv6");

    ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
    ptr = sizeof(_iph);

    currenthdr = ih->nexthdr;
    DEBUG_PRINT("start opt loop");
    while (currenthdr != NEXTHDR_NONE && ip6t_ext_hdr(currenthdr)) {
        DEBUG_PRINT("optloop %u", currenthdr);
        hp = skb_header_pointer(skb, ptr, sizeof(_hdr), &_hdr);
        if (hp == NULL) {
            return false;
        }
        switch (currenthdr) {
        case IPPROTO_FRAGMENT:
            hdrlen = 8;
            break;
        case IPPROTO_DSTOPTS:
        case IPPROTO_ROUTING:
        case IPPROTO_HOPOPTS:
            hdrlen = ipv6_optlen(hp);
            break;
        case IPPROTO_AH:
            hdrlen = (hp->hdrlen + 2) << 2;
            break;
        }
        currenthdr = hp->nexthdr;
        ptr += hdrlen;
    }
    if (currenthdr == IPPROTO_UDP) {
        return dns_mt_udp(skb, par, ptr);
    }
    if (currenthdr == IPPROTO_TCP) {
        return dns_mt_tcp(skb, par, ptr);
    }
    DEBUG_PRINT("unsupported protocol.");
    return false;
}

static struct xt_match dns_mt_reg[] __read_mostly = {
    {
        .name = "dns",
        .table = "filter",
        .family = NFPROTO_IPV4,
        .match = dns_mt4,
        .matchsize = sizeof(struct xt_dns),
        .me = THIS_MODULE,
    },
    {
        .name = "dns",
        .table = "filter",
        .family = NFPROTO_IPV6,
        .match = dns_mt6,
        .matchsize = sizeof(struct xt_dns),
        .me = THIS_MODULE,
    }};
static int __init dns_mt_init(void) {
    return xt_register_matches(dns_mt_reg, ARRAY_SIZE(dns_mt_reg));
}

static void __exit dns_mt_exit(void) {
    xt_unregister_matches(dns_mt_reg, ARRAY_SIZE(dns_mt_reg));
}

module_init(dns_mt_init);
module_exit(dns_mt_exit);
