from setuptools import setup, find_packages

setup(
    name="custom-flink-connector",
    version="0.0.1",
    description="Custom Flink Connector for OpenMetadata",
    python_requires=">=3.10",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    entry_points={
        "openmetadata.ingestion.source": [
            "CustomFlink = custom_flink.metadata:CustomFlinkSource"
        ]
    },
    install_requires=[
        "openmetadata-ingestion==1.11.4",
    ],
)
