describe YetiException::Helpers do
  describe '#raise_exception' do
    let(:klass) do
      Class.new do
        include YetiException::Helpers

        def boom
          raise_exception(YetiException::Error,
                          { some: 'details' },
                          false,
                          400)
        end
      end
    end

    subject { klass.new.boom }

    it 'raises the requested exception' do
      expect { subject }.to raise_error do |error|
        expect(error).to be_a(YetiException::Error)
        expect(error.klass).to eq(klass)
        expect(error.details).to eq({ some: 'details' })
        expect(error.transient).to eq(false)
        expect(error.http_status).to eq(400)
      end
    end

    context 'when extra params are omitted' do
      let(:klass) do
        Class.new do
          include YetiException::Helpers

          def boom
            raise_exception(YetiException::Error,
                            { some: 'details' })
          end
        end
      end

      it 'raises the requested exception with defaults' do
        expect { subject }.to raise_error do |error|
          expect(error.transient).to eq(true)
          expect(error.http_status).to eq(500)
        end
      end
    end
  end

  describe '.raise_exception' do
    let(:klass) do
      Class.new do
        include YetiException::Helpers

        def self.boom
          raise_exception(YetiException::Error,
                          { some: 'details' },
                          false,
                          400)
        end
      end
    end

    subject { klass.boom }

    it 'raises the requested exception' do
      expect { subject }.to raise_error do |error|
        expect(error).to be_a(YetiException::Error)
        expect(error.klass).to eq(klass)
        expect(error.details).to eq({ some: 'details' })
        expect(error.transient).to eq(false)
        expect(error.http_status).to eq(400)
      end
    end

    context 'when extra params are omitted' do
      let(:klass) do
        Class.new do
          include YetiException::Helpers

          def self.boom
            raise_exception(YetiException::Error,
                            { some: 'details' })
          end
        end
      end

      it 'raises the requested exception with defaults' do
        expect { subject }.to raise_error do |error|
          expect(error.transient).to eq(true)
          expect(error.http_status).to eq(500)
        end
      end
    end
  end
end
