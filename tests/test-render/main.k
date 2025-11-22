
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_composition = "apis/accounts/composition.yaml"
_xrd = "apis/accounts/definition.yaml"

_root_org_observation = {
    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
    kind: "Organization"
    metadata: {
        name: "example-root-organization"
        annotations: {
            "gotemplating.fn.crossplane.io/composition-resource-name": "organization"
            "crossplane.io/composition-resource-name": "organization"
        }
    }
    status: {
        conditions: [
            {
                type: "Ready"
                status: "True"
            }
        ]
        atProvider: {
            id: "o-example-root"
            roots: [
                {
                    id: "r-example-root"
                }
            ]
        }
    }
}

_nested_org_observation = {
    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
    kind: "Organization"
    metadata: {
        name: "example-nested-organization"
        annotations: {
            "gotemplating.fn.crossplane.io/composition-resource-name": "organization"
            "crossplane.io/composition-resource-name": "organization"
        }
    }
    status: {
        conditions: [
            {
                type: "Ready"
                status: "True"
            }
        ]
        atProvider: {
            id: "o-example-nested"
            roots: [
                {
                    id: "r-example-nested"
                }
            ]
        }
    }
}

_nested_ou0_observation = {
    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
    kind: "OrganizationalUnit"
    metadata: {
        name: "example-nested-ou-platform-team-0"
        annotations: {
            "gotemplating.fn.crossplane.io/composition-resource-name": "organizational-unit-0"
            "crossplane.io/composition-resource-name": "organizational-unit-0"
        }
    }
    status: {
        conditions: [
            {
                type: "Ready"
                status: "True"
            }
        ]
        atProvider: {
            id: "ou-platform-team"
        }
    }
}

_nested_ou1_observation = {
    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
    kind: "OrganizationalUnit"
    metadata: {
        name: "example-nested-ou-prod-1"
        annotations: {
            "gotemplating.fn.crossplane.io/composition-resource-name": "organizational-unit-1"
            "crossplane.io/composition-resource-name": "organizational-unit-1"
        }
    }
    status: {
        conditions: [
            {
                type: "Ready"
                status: "True"
            }
        ]
        atProvider: {
            id: "ou-prod"
        }
    }
}

_nested_ou2_observation = {
    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
    kind: "OrganizationalUnit"
    metadata: {
        name: "example-nested-ou-saas-2"
        annotations: {
            "gotemplating.fn.crossplane.io/composition-resource-name": "organizational-unit-2"
            "crossplane.io/composition-resource-name": "organizational-unit-2"
        }
    }
    status: {
        conditions: [
            {
                type: "Ready"
                status: "True"
            }
        ]
        atProvider: {
            id: "ou-saas"
        }
    }
}

_nested_account_observation = {
    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
    kind: "Account"
    metadata: {
        name: "example-nested-account"
        annotations: {
            "gotemplating.fn.crossplane.io/composition-resource-name": "member-account"
            "crossplane.io/composition-resource-name": "member-account"
        }
    }
    status: {
        conditions: [
            {
                type: "Ready"
                status: "True"
            }
        ]
        atProvider: {
            id: "123456789012"
            email: "nested-owner@example.com"
        }
    }
}

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "test-account-root-organization-and-member"
        spec = {
            compositionPath: _composition
            xrPath: "examples/accounts/example-root.yaml"
            xrdPath: _xrd
            timeoutSeconds: 180
            validate: True
            observedResources: [
                _root_org_observation
            ]
            assertResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Organization"
                    metadata: {
                        name: "example-root-organization"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            name: "management-aws"
                        }
                        forProvider: {
                            featureSet: "ALL"
                        }
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Account"
                    metadata: {
                        name: "example-root-account"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            name: "management-aws"
                        }
                        forProvider: {
                            name: "Example Root"
                            email: "example-root@accounts.example.com"
                            parentId: "r-example-root"
                            tags: {
                                hops: "true"
                                workspace: "example"
                            }
                        }
                    }
                }
            ]
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name: "test-account-ou-chain-and-scp-attachments"
        spec = {
            compositionPath: _composition
            xrPath: "examples/accounts/example-nested.yaml"
            xrdPath: _xrd
            timeoutSeconds: 180
            validate: True
            observedResources: [
                _nested_org_observation,
                _nested_ou0_observation,
                _nested_ou1_observation,
                _nested_ou2_observation,
                _nested_account_observation
            ]
            assertResources: [
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Organization"
                    metadata: {
                        name: "example-nested-organization"
                    }
                    spec: {
                        managementPolicies: ["Observe", "LateInitialize"]
                        providerConfigRef: {
                            name: "management-aws"
                        }
                        forProvider: {
                            featureSet: "ALL"
                        }
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "OrganizationalUnit"
                    metadata: {
                        name: "example-nested-ou-prod-1"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            name: "management-aws"
                        }
                        forProvider: {
                            name: "Prod"
                            parentId: "ou-platform-team"
                        }
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "Account"
                    metadata: {
                        name: "example-nested-account"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            name: "management-aws"
                        }
                        forProvider: {
                            name: "Example Nested"
                            email: "nested-owner@example.com"
                            parentId: "ou-saas"
                            tags: {
                                hops: "true"
                                team: "platform"
                                tier: "shared"
                            }
                        }
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "PolicyAttachment"
                    metadata: {
                        name: "example-nested-scp-0"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            name: "management-aws"
                        }
                        forProvider: {
                            policyArn: "arn:aws:organizations::111111111111:policy/o-example/p-require-tags"
                        }
                    }
                },
                {
                    apiVersion: "organizations.aws.m.upbound.io/v1beta1"
                    kind: "PolicyAttachment"
                    metadata: {
                        name: "example-nested-scp-1"
                    }
                    spec: {
                        managementPolicies: ["*"]
                        providerConfigRef: {
                            name: "management-aws"
                        }
                        forProvider: {
                            policyArn: "arn:aws:organizations::111111111111:policy/o-example/p-block-public-s3"
                        }
                    }
                },
                {
                    apiVersion: "aws.m.upbound.io/v1beta1"
                    kind: "ProviderConfig"
                    metadata: {
                        name: "example-nested-provider"
                    }
                    spec: {
                        credentials: {
                            source: "IRSA"
                        }
                        assumeRoleChain: [
                            {
                                roleARN: "arn:aws:iam::123456789012:role/OrganizationAccountAccessRole"
                            }
                        ]
                    }
                }
            ]
        }
    }
]
items = _items
