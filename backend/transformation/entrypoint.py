from service import TransformLayer
from example import data_example


def main():
    transformer = TransformLayer()
    transformed_data = transformer.transform(data=data_example)
    print(transformed_data)


if __name__ == '__main__':
    main()
